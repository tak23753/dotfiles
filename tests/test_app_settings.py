"""Check iTerm2/AltTab migration without touching real apps or Alfred settings."""
from contextlib import redirect_stdout
import importlib.util
import io
import json
import os
from pathlib import Path
import plistlib
import shutil
import subprocess
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("app_settings", ROOT / "scripts/app-settings.py")
APP = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(APP)


class AppSettingsTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="dotfiles-apps-")
        self.addCleanup(temporary.cleanup)
        self.base = Path(temporary.name)
        self.repo = self.base / "repo with spaces"
        self.home = self.base / "new home & user's files"
        self.home.mkdir()
        shutil.copytree(ROOT / "apps", self.repo / "apps",
                        ignore=shutil.ignore_patterns("Alfred.alfredpreferences"))
        self.defaults = {"com.googlecode.iterm2": {"existing-unmanaged-setting": "keep"}}
        self.calls = []

        def command(args, **kwargs):
            self.calls.append(args)
            if args[0] == "pgrep":
                return subprocess.CompletedProcess(args, 1)
            if args[:2] == ["defaults", "export"]:
                self.assertNotIn("Alfred", args[2])
                return subprocess.CompletedProcess(args, 0, plistlib.dumps(self.defaults.get(args[2], {})))
            if args[:2] == ["defaults", "import"]:
                self.assertNotIn("Alfred", args[2])
                self.defaults[args[2]] = plistlib.loads(Path(args[3]).read_bytes())
                return subprocess.CompletedProcess(args, 0)
            self.fail("Unexpected external command: " + repr(args))

        self.command = command
        self.addCleanup(patch.stopall)
        patch.object(APP.subprocess, "run", side_effect=command).start()

    def apply(self):
        output = io.StringIO()
        with redirect_stdout(output):
            APP.apply(self.repo, self.home)
        return output.getvalue()

    def test_defaults_relocation_backup_and_idempotency(self):
        output = self.apply()
        self.assertIn("Set preferences folder", output)
        self.assertIn(str(self.repo / "apps/alfred"), output)
        values = self.defaults[APP.ITERM]
        self.assertEqual(values["existing-unmanaged-setting"], "keep")
        self.assertEqual(values["PrefsCustomFolder"], str(self.home / ".config/iterm2"))
        self.assertTrue(values["LoadPrefsFromCustomFolder"])
        bookmarks = values["New Bookmarks"]
        self.assertEqual(bookmarks[0]["Working Directory"], str(self.home))
        self.assertTrue(bookmarks[0]["Log Directory"].startswith(str(self.home)))
        self.assertIn(APP.ALTTAB, self.defaults)
        exported = list((self.home / "Library/Preferences").glob(APP.ITERM + ".plist.backup.*/original"))
        self.assertEqual(len(exported), 1)
        self.assertEqual(plistlib.loads(exported[0].read_bytes()), {"existing-unmanaged-setting": "keep"})
        count = len([call for call in self.calls if call[:2] == ["defaults", "import"]])
        self.apply()
        self.assertEqual(len([call for call in self.calls if call[:2] == ["defaults", "import"]]), count)
        self.assertEqual(len(list(self.home.rglob("*.backup.*"))), 1)

    def test_apply_leaves_running_alfred_and_its_settings_untouched(self):
        support = self.home / "Library/Application Support/Alfred"
        support.mkdir(parents=True)
        state = {"current": str(self.repo / "apps/alfred/Alfred.alfredpreferences"), "localhash": "this-mac"}
        state_file = support / "prefs.json"
        state_file.write_text(json.dumps(state))
        original = state_file.read_bytes()

        def running(args, **kwargs):
            if args[:2] == ["pgrep", "-x"] and args[2] in ["Alfred", "Alfred Preferences"]:
                return subprocess.CompletedProcess(args, 0)
            return self.command(args, **kwargs)

        with patch.object(APP.subprocess, "run", side_effect=running):
            self.apply()
        self.assertEqual(state_file.read_bytes(), original)
        self.assertEqual([p.name for p in support.iterdir()], ["prefs.json"])

    def test_running_iterm_aborts_before_changing_gui_preferences(self):
        def running(args, **kwargs):
            if args == ["pgrep", "-x", "iTerm2"]:
                return subprocess.CompletedProcess(args, 0)
            return self.command(args, **kwargs)
        with patch.object(APP.subprocess, "run", side_effect=running):
            with self.assertRaisesRegex(RuntimeError, "Quit iTerm2"):
                self.apply()
        self.assertEqual(list(self.home.iterdir()), [])

    def test_capture_six_apps_keeps_directly_edited_alfred_files(self):
        for source, destination in [
            ("apps/linearmouse/linearmouse.json", ".config/linearmouse/linearmouse.json"),
            ("apps/uv/uv.toml", ".config/uv/uv.toml"),
            ("apps/colima/colima.yaml", ".colima/default/colima.yaml"),
            ("apps/k9s/config.yaml", "Library/Application Support/k9s/config.yaml"),
            ("apps/k9s/plugins.yaml", "Library/Application Support/k9s/plugins.yaml"),
            ("apps/k9s/aliases.yaml", "Library/Application Support/k9s/aliases.yaml"),
        ]:
            path = self.home / destination
            path.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(ROOT / source, path)
        self.defaults[APP.ITERM] = {"New Bookmarks": [{"Working Directory": str(self.home)}],
                                    "NoSyncInstallationId": "old-machine-id"}
        self.defaults[APP.ALTTAB] = {"rowsCount": "3", "MSAppCenterInstallId": "old-machine-id"}
        native = self.repo / "apps/alfred/Alfred.alfredpreferences/workflows/edited/info.plist"
        APP.write_plist(native, {"name": "Edited directly in Alfred"})
        original = native.read_bytes()
        with patch.dict(os.environ, {"K9S_CONFIG_DIR": str(self.home / "Library/Application Support/k9s")}):
            with redirect_stdout(io.StringIO()):
                APP.capture(self.repo, self.home)
        exported = plistlib.loads((self.repo / "apps/iterm2/preferences.plist").read_bytes())
        self.assertEqual(exported["New Bookmarks"][0]["Working Directory"], APP.HOME_TOKEN)
        self.assertNotIn("NoSyncInstallationId", exported)
        self.assertEqual(native.read_bytes(), original)
        self.assertFalse((self.home / "Library/Application Support/Alfred").exists())


if __name__ == "__main__":
    unittest.main()

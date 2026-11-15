"""Run setup against a temporary HOME and mock all external setup commands."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]

MOCK_TOOL = r'''
import json
import os
from pathlib import Path
import subprocess
import sys

tool = Path(sys.argv[0]).name
args = sys.argv[1:]
record = [tool, *args]
if tool == "cp" and args[1].endswith("/Library/Fonts/"):
    record = [tool, Path(args[0]).name, "~/Library/Fonts/"]
with open(os.environ["TEST_SETUP_TRACE"], "a") as stream:
    stream.write(json.dumps(record) + "\n")
if tool == os.environ.get("TEST_FAIL_TOOL") and args != ["shellenv"]:
    if tool != "cp" or args[1].endswith("/Library/Fonts/"):
        sys.exit(23)
if tool == "defaults" and args[:1] == ["read"]:
    sys.exit(0 if os.environ["TEST_GLOBAL_PRESS_HOLD"] == "present" else 1)
if tool == "defaults" and args[:1] == ["export"]:
    import plistlib
    sys.stdout.buffer.write(plistlib.dumps({}))
if tool == "pgrep":
    sys.exit(1)  # No GUI app is running in this isolated setup.
if tool == "killall":
    sys.exit(1)  # An app not running must not abort setup.
if tool == "brew" and args == ["bundle", "--global"]:
    assert (Path.home() / ".Brewfile").is_file()
if tool == "mise":
    assert (Path.home() / ".config/mise/config.toml").is_file()
if tool == "cp":
    sys.exit(subprocess.call(["/bin/cp", *args]))
'''


def run_setup(repo, home, *, failure="", press_hold="present", links_only=False):
    home.mkdir(parents=True)
    # Keep local drafts and backups out of the isolated test checkout.
    isolated_repo = home.parent / "isolated dotfiles"
    shutil.copytree(repo, isolated_repo, ignore=shutil.ignore_patterns(".git", ".local", "__pycache__"))
    tools = home.parent / "mock tools"
    tools.mkdir()
    for name in ("brew", "defaults", "killall", "mise", "gcloud", "cp", "pgrep"):
        executable = tools / name
        executable.write_text(f"#!{sys.executable}\n" + MOCK_TOOL)
        executable.chmod(0o755)
    trace = home.parent / "setup.trace"
    trace.write_text("")
    bash_env = home.parent / "setup-env.sh"
    # Intercept the installer's absolute Homebrew shellenv calls as well.
    bash_env.write_text('''
export PATH="$TEST_TOOL_DIR:/usr/bin:/bin:/usr/sbin:/sbin"
function /opt/homebrew/bin/brew { "$TEST_TOOL_DIR/brew" "$@"; }
function /usr/local/bin/brew { "$TEST_TOOL_DIR/brew" "$@"; }
''')
    env = dict(os.environ, HOME=str(home), BASH_ENV=str(bash_env),
               TEST_TOOL_DIR=str(tools), TEST_SETUP_TRACE=str(trace),
               TEST_FAIL_TOOL=failure, TEST_GLOBAL_PRESS_HOLD=press_hold)
    args = ["/bin/bash", str(isolated_repo / "install.sh")]
    if links_only:
        args.append("--links-only")
    result = subprocess.run(args, cwd=home.parent, env=env, text=True, capture_output=True)
    records = [json.loads(line) for line in trace.read_text().splitlines()]
    return result, records


class SetupTests(unittest.TestCase):
    def test_full_setup_order_and_assets(self):
        with tempfile.TemporaryDirectory(prefix="dotfiles-setup-") as directory:
            home = Path(directory) / "home with spaces"
            result, records = run_setup(ROOT, home)
            self.assertEqual(result.returncode, 0, result.stderr)
            bundle = records.index(["brew", "bundle", "--global"])
            self.assertIn(["defaults", "write", "com.apple.dock", "autohide", "-bool", "true"], records[:bundle])
            self.assertIn(["defaults", "write", "com.microsoft.VSCode", "ApplePressAndHoldEnabled", "-bool", "false"], records[:bundle])
            self.assertEqual(records[bundle + 1:bundle + 5], [
                ["cp", "MesloLGS NF Regular.ttf", "~/Library/Fonts/"],
                ["cp", "SourceHanCodeJP.ttc", "~/Library/Fonts/"],
                ["mise", "--cd", str(home), "install"],
                ["gcloud", "components", "install", "--quiet", "gke-gcloud-auth-plugin"],
            ])
            gui_records = records[bundle + 5:]
            self.assertIn(["pgrep", "-x", "iTerm2"], gui_records)
            self.assertFalse(any("Alfred" in argument for row in gui_records for argument in row))
            for domain in ("com.googlecode.iterm2", "com.lwouis.alt-tab-macos"):
                self.assertTrue(any(row[:3] == ["defaults", "import", domain] for row in gui_records))
            for font in (ROOT / "system/fonts").iterdir():
                self.assertEqual((home / "Library/Fonts" / font.name).read_bytes(), font.read_bytes())
            # The dictionary was an unused asset before the refactor too.
            self.assertFalse((home / "Library/Dictionaries").exists())

    def test_links_only_skips_setup_commands(self):
        with tempfile.TemporaryDirectory(prefix="dotfiles-setup-") as directory:
            home = Path(directory) / "home"
            result, records = run_setup(ROOT, home, links_only=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            # Writable app config files are copied, but no install/defaults
            # commands or GUI preference restoration run in links-only mode.
            self.assertEqual([row[0] for row in records], ["cp", "cp"])
            self.assertEqual([Path(row[1]).name for row in records], ["config.yaml", "colima.yaml"])
            # k9s uses its native macOS config directory even in links-only mode.
            self.assertTrue((home / "Library/Application Support/k9s/plugins.yaml").is_file())
            self.assertFalse((home / "Library/Application Support/Alfred").exists())

    def test_setup_stops_when_tool_installation_fails(self):
        for tool in ("brew", "cp", "mise"):
            with self.subTest(tool=tool), tempfile.TemporaryDirectory(prefix="dotfiles-setup-") as directory:
                result, records = run_setup(ROOT, Path(directory) / "home", failure=tool)
                self.assertEqual(result.returncode, 23, result.stderr)
                self.assertEqual(records[-1][0], tool)
                self.assertNotIn("gcloud", [record[0] for record in records])


if __name__ == "__main__":
    unittest.main()

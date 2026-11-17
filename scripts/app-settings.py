#!/usr/bin/env python3
"""Capture six app settings, or restore iTerm2, AltTab and Alfred after Homebrew setup.

Uses only the standard library. Capturing reads the current Mac but writes only
inside dotfiles; applying never launches or terminates applications, skips apps
that are already up to date, and can be rerun after quitting any skipped app.
"""
import argparse
import json
import os
from pathlib import Path
import plistlib
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
HOME_TOKEN = "__DOTFILES_HOME__"
ITERM = "com.googlecode.iterm2"
ALTTAB = "com.lwouis.alt-tab-macos"


def replace_home(value, old, new):
    if isinstance(value, str):
        return value.replace(old, new)
    if isinstance(value, list):
        return [replace_home(item, old, new) for item in value]
    if isinstance(value, dict):
        return {key: replace_home(item, old, new) for key, item in value.items()}
    return value


def read_defaults(domain):
    result = subprocess.run(["defaults", "export", domain, "-"], capture_output=True)
    # macOS exports an empty dictionary for a missing domain. Other failures
    # must not be mistaken for an empty domain and overwrite existing settings.
    result.check_returncode()
    return plistlib.loads(result.stdout)


def write_plist(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(plistlib.dumps(value, sort_keys=True))


def backup(path):
    directory = Path(tempfile.mkdtemp(prefix=path.name + ".backup.", dir=path.parent))
    shutil.move(str(path), str(directory / "original"))
    print("Backed up {} to {}/original".format(path, directory))


def is_installed(path, content):
    return path.is_file() and not path.is_symlink() and path.read_bytes() == content


def install_bytes(path, content):
    path.parent.mkdir(parents=True, exist_ok=True)
    if is_installed(path, content):
        return
    if path.exists() or path.is_symlink():
        backup(path)
    path.write_bytes(content)


def running_processes(names):
    running = []
    for process in names:
        result = subprocess.run(["pgrep", "-x", process], stdout=subprocess.DEVNULL,
                                stderr=subprocess.PIPE)
        if result.returncode == 0:
            running.append(process)
        elif result.returncode != 1:
            result.check_returncode()
    return running


def restore(home, process, domain, settings, files=()):
    current = read_defaults(domain)
    updated = dict(current)
    updated.update(settings)
    if updated == current and all(is_installed(path, content) for path, content in files):
        return
    # A running app would overwrite restored preferences when it quits.
    if running_processes([process]):
        print("Skipped {0} preferences. Quit {0} and rerun install.sh to restore them.".format(process))
        return
    for path, content in files:
        install_bytes(path, content)
    if updated == current:
        return
    # Keep a restorable export; do not copy the potentially stale on-disk plist.
    if current:
        parent = home / "Library/Preferences"
        parent.mkdir(parents=True, exist_ok=True)
        directory = Path(tempfile.mkdtemp(prefix=domain + ".plist.backup.", dir=parent))
        write_plist(directory / "original", current)
        os.chmod(directory / "original", 0o600)
    with tempfile.TemporaryDirectory(prefix="dotfiles-defaults-") as directory:
        path = Path(directory) / "preferences.plist"
        write_plist(path, updated)
        subprocess.run(["defaults", "import", domain, str(path)], check=True)


def capture(root, home):
    def portable(value):
        return replace_home(value, str(home), HOME_TOKEN)

    for name, domain in [("iterm2", ITERM), ("alttab", ALTTAB)]:
        values = read_defaults(domain)
        if not values:
            raise RuntimeError("No preferences found for " + domain)
        # Machine IDs, crash reports, window positions and update history are
        # transient. Keep actual app settings, including automatic-update choices.
        ignored = ("NoSync", "NSWindow", "NSNav", "NSOSPLast", "MSAppCenter")
        excluded = {"PrefsCustomFolder", "LoadPrefsFromCustomFolder", "SULastCheckTime",
                    "SUHasLaunchedBefore", "SUUpdateGroupIdentifier", "SUUpdateRelaunchingMarker",
                    "UKCrashReporterLastCrashReportDate"}
        values = {k: v for k, v in values.items()
                  if not k.startswith(ignored) and k not in excluded}
        write_plist(root / "apps" / name / "preferences.plist", portable(values))

    for source, target in [
        (".config/linearmouse/linearmouse.json", "linearmouse/linearmouse.json"),
        (".config/uv/uv.toml", "uv/uv.toml"),
        (".colima/default/colima.yaml", "colima/colima.yaml"),
    ]:
        path = root / "apps" / target
        path.parent.mkdir(parents=True, exist_ok=True)
        # These files have no home paths. Reject rather than introduce an
        # unexpanded template into a file that is deployed by the shell linker.
        content = (home / source).read_text()
        if str(home) in content:
            raise RuntimeError("Review machine-specific path in " + source)
        path.write_text("\n".join(line.rstrip() for line in content.splitlines()) + "\n")

    # Respect an explicit override; otherwise use the native macOS location,
    # rather than the old, unused ~/.config/k9s/plugins.yaml.
    k9s = Path(os.environ.get("K9S_CONFIG_DIR", str(home / "Library/Application Support/k9s")))
    for name in ["config.yaml", "aliases.yaml", "plugins.yaml"]:
        content = (k9s / name).read_text()
        if name == "config.yaml":
            # Let k9s derive its screen-dump location from the new Mac's HOME.
            content = "\n".join(line for line in content.splitlines()
                                if not line.startswith("  screenDumpDir:")) + "\n"
        if str(home) in content:
            raise RuntimeError("Review machine-specific path in k9s/" + name)
        path = root / "apps/k9s" / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)

    print("Captured six apps into dotfiles. Alfred edits its Git-managed settings directly.")


def apply(root, home):
    snapshot = plistlib.loads((root / "apps/iterm2/preferences.plist").read_bytes())
    snapshot = replace_home(snapshot, HOME_TOKEN, str(home))
    iterm_folder = home / ".config/iterm2"
    # Import as well as configure the custom folder, so the first launch has the
    # correct settings even before iTerm2 has loaded its custom-folder preference.
    settings = dict(snapshot, PrefsCustomFolder=str(iterm_folder), LoadPrefsFromCustomFolder=True)
    restore(home, "iTerm2", ITERM, settings,
            [(iterm_folder / (ITERM + ".plist"), plistlib.dumps(snapshot))])

    settings = plistlib.loads((root / "apps/alttab/preferences.plist").read_bytes())
    restore(home, "AltTab", ALTTAB, replace_home(settings, HOME_TOKEN, str(home)))
    link_alfred(root, home)


def link_alfred(root, home):
    preferences = root / "apps/alfred/Alfred.alfredpreferences"
    shared = root / "apps/alfred/local-preferences"
    state_file = home / "Library/Application Support/Alfred/prefs.json"
    state = json.loads(state_file.read_text()) if state_file.is_file() else {}
    # Alfred writes this Mac's hash only after its first launch.
    if not state.get("localhash") or not state.get("current") \
            or Path(state["current"]).resolve() != preferences.resolve():
        print("Alfred: activate Powerpack, then choose Advanced > Set preferences folder... > "
              + str(root / "apps/alfred") + ". Then quit Alfred and rerun install.sh.")
        return
    # Alfred keeps hotkey, appearance and search scope under a per-Mac hash.
    # Point this Mac's folder at the shared, Git-managed copy.
    local = preferences / "preferences/local" / state["localhash"]
    if local.is_symlink() and local.resolve() == shared.resolve():
        return
    running = running_processes(["Alfred", "Alfred Preferences"])
    if running:
        print("Skipped Alfred preferences. Quit {} and rerun install.sh to share them."
              .format(", ".join(running)))
        return
    local.parent.mkdir(parents=True, exist_ok=True)
    if local.exists() or local.is_symlink():
        backup(local)
    local.symlink_to(os.path.relpath(shared, local.parent))
    print("Alfred now uses the shared preferences in " + str(shared))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=["capture", "apply"])
    args = parser.parse_args()
    if sys.platform != "darwin":
        parser.error("This script supports macOS only")
    try:
        {"capture": capture, "apply": apply}[args.command](ROOT, Path.home())
    except (RuntimeError, OSError, ValueError, subprocess.CalledProcessError) as error:
        parser.exit(1, "App settings: {}\n".format(error))


if __name__ == "__main__":
    main()

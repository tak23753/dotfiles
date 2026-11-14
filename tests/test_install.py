"""Integration checks for file deployment; no package installs or home changes."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class InstallTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="dotfiles-test-")
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name).resolve()
        self.home = self.base / "home with spaces"
        self.home.mkdir()
        self.env = dict(os.environ, HOME=str(self.home))
        self.company = self.base / "company settings"
        self.company.mkdir()
        self.ssh = self.company / "ssh.conf"
        self.ssh.write_text("Host company-test\n  HostName 192.0.2.10\n  User company-user\n")
        self.zsh = self.company / "shell.zsh"
        self.zsh.write_text("export DOTFILES_TEST_SETTING=company\n")

    def install(self, *args, success=True):
        result = subprocess.run(
            ["bash", str(ROOT / "install.sh"), "--links-only", *map(str, args)],
            cwd=self.base, env=self.env, text=True, capture_output=True,
        )
        if success:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0)
        return result

    def snapshot(self):
        return {
            str(p.relative_to(self.home)): (
                ("link", os.readlink(p)) if p.is_symlink()
                else ("dir",) if p.is_dir() else ("file", p.read_bytes())
            )
            for p in self.home.rglob("*")
        }

    def shell_setting(self):
        # Test the real loader without starting interactive plugins or network setup.
        command = 'source "$HOME/.zsh/additional-settings.zsh"; print -r -- "${DOTFILES_TEST_SETTING:-none}"'
        return subprocess.check_output(
            ["zsh", "-f", "-c", command], env=self.env, text=True,
        ).strip()

    def test_personal_only_and_repeat(self):
        self.install()
        self.assertEqual(self.shell_setting(), "none")
        self.assertFalse((self.home / ".git").exists())
        self.assertFalse((self.home / ".local").exists())
        first = self.snapshot()
        self.install()
        self.assertEqual(self.snapshot(), first)
        self.assertIn('source "$HOME/.zsh/additional-settings.zsh"', (ROOT / ".zshrc").read_text())

    def test_injection_loading_and_repeat(self):
        self.install("--extra-ssh-config", self.ssh, "--extra-zsh-config", self.zsh)
        self.assertEqual(self.shell_setting(), "company")
        self.assertEqual((self.home / ".config/dotfiles/extra.zsh").resolve(), self.zsh)
        # ssh -G expands configuration without connecting to a server.
        result = subprocess.run(
            ["ssh", "-G", "-F", str(self.home / ".ssh/config.d/50-extra.conf"), "company-test"],
            env=self.env, text=True, capture_output=True, check=True,
        )
        self.assertIn("hostname 192.0.2.10", result.stdout)
        self.assertIn("user company-user", result.stdout)
        # OpenSSH expands ~ using the OS account rather than $HOME, so replace
        # only that prefix in a disposable copy to exercise the actual Include.
        ssh_config = (self.home / ".ssh/config").read_text()
        ssh_config = ssh_config.replace(
            "Include ~/.ssh/config.d/*.conf",
            'Include "' + str(self.home / ".ssh/config.d/*.conf") + '"',
        ).replace(
            "Include ~/.colima/ssh_config",
            'Include "' + str(self.home / ".colima/ssh_config") + '"',
        )
        check_config = self.base / "ssh config"
        check_config.write_text(ssh_config)
        result = subprocess.run(
            ["ssh", "-G", "-F", str(check_config), "company-test"],
            text=True, capture_output=True, check=True,
        )
        self.assertIn("user company-user", result.stdout)
        first = self.snapshot()
        self.install("--extra-ssh-config", self.ssh, "--extra-zsh-config", self.zsh)
        self.assertEqual(self.snapshot(), first)
        self.install()  # Omitted flags preserve existing extra settings.
        self.assertEqual(self.snapshot(), first)
        self.install(
            "--extra-zsh-config", self.home / ".config/dotfiles/extra.zsh",
            "--extra-ssh-config", self.home / ".ssh/config.d/50-extra.conf",
        )
        self.assertEqual(self.snapshot(), first)
        # The final local override is preserved and loaded last.
        (self.home / ".config/dotfiles/local.zsh").write_text("export DOTFILES_TEST_SETTING=local\n")
        self.install()
        self.assertEqual(self.shell_setting(), "local")

    def test_independent_flags_relative_paths_and_switch(self):
        self.install("--extra-zsh-config", self.zsh.relative_to(self.base))
        self.assertFalse((self.home / ".ssh/config.d/50-extra.conf").exists())
        self.install("--extra-ssh-config", self.ssh.relative_to(self.base))
        self.assertEqual(self.shell_setting(), "company")
        other = self.company / "other.zsh"
        other.write_text("export DOTFILES_TEST_SETTING=other\n")
        self.install("--extra-zsh-config", other)
        self.assertEqual(self.shell_setting(), "other")
        backups = list((self.home / ".config/dotfiles").glob("extra.zsh.backup.*/original"))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].resolve(), self.zsh)
        self.assertEqual((self.home / ".ssh/config.d/50-extra.conf").resolve(), self.ssh)
        first = self.snapshot()
        self.install("--extra-zsh-config", other)
        self.assertEqual(self.snapshot(), first)

    def test_existing_files_directories_and_dangling_links_are_preserved(self):
        (self.home / ".zshrc").write_text("old zshrc\n")
        (self.home / ".zsh").mkdir()
        (self.home / ".zsh/old").write_text("old directory\n")
        (self.home / ".vimrc").symlink_to(self.home / "missing-target")
        self.install()
        for name, expected in [(".zshrc", "old zshrc\n"), (".zsh", "old directory\n")]:
            backups = list(self.home.glob(name + ".backup.*/original"))
            self.assertEqual(len(backups), 1)
            original = backups[0] / "old" if name == ".zsh" else backups[0]
            self.assertEqual(original.read_text(), expected)
        backup = list(self.home.glob(".vimrc.backup.*"))[0] / "original"
        self.assertTrue(backup.is_symlink())
        first = self.snapshot()
        self.install()
        self.assertEqual(self.snapshot(), first)

    def test_invalid_arguments_do_not_change_home(self):
        for args in [
            ("--extra-ssh-config",),
            ("--extra-zsh-config", self.base / "missing"),
            ("--extra-zsh-config", self.company),
            ("--extra-zsh-config", ROOT / ".zshrc"),
            ("--extra-ssh-config", ROOT / "mac/etc/.ssh/config"),
            ("--extra-ssh-config", self.ssh, "--unknown"),
            ("--extra-ssh-config", self.ssh, "--extra-ssh-config", self.ssh),
        ]:
            with self.subTest(args=args):
                self.install(*args, success=False)
                self.assertEqual(self.snapshot(), {})


if __name__ == "__main__":
    unittest.main()

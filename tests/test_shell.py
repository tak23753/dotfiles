"""Exercise complete Zsh startup with tool hooks replaced by local fixtures."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
FIXTURE = ROOT / "tests/fixtures/shell-tools.zsh"


def prepare_shell_home(home):
    """Create only the external files the existing startup expects."""
    files = {
        ".local/share/zinit/zinit.git/zinit.zsh": "trace zinit-source\n",
        ".sdkman/bin/sdkman-init.sh": (
            'trace "sdkman PATH=$PATH"\nexport PATH="$HOME/sdk/bin:$PATH"\n'
        ),
        "brew/share/google-cloud-sdk/path.zsh.inc": "trace gcloud-path\n",
        "brew/share/google-cloud-sdk/completion.zsh.inc": "trace gcloud-completion\n",
        ".cache/p10k-instant-prompt-test.zsh": "trace instant-prompt\n",
        ".config/op/plugins.sh": "trace op\nexport TEST_OP=loaded\n",
    }
    for name, content in files.items():
        target = home / name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content)


def shell_snapshot(home, fixture=FIXTURE):
    trace = home / "startup.trace"
    trace.write_text("")
    # Disable user startup files, then explicitly load the installed entry point.
    command = r'''
builtin source "$TEST_FIXTURE"
builtin source "$HOME/.zshrc"
print -r -- '--- environment ---'
for setting in PATH HISTFILE HISTSIZE SAVEHIST WORDCHARS SSH_AUTH_SOCK GOPATH ANDROID_HOME ANDROID_SDK_ROOT POWERLEVEL9K_INSTANT_PROMPT TEST_DIRENV TEST_ZOXIDE TEST_MISE TEST_FZF TEST_OP TEST_OVERRIDE; do
  print -r -- "$setting=${(P)setting}"
done
print -r -- '--- aliases ---'
alias -L
print -r -- '--- options ---'
setopt
print -r -- '--- bindings ---'
bindkey -L
print -r -- '--- styles ---'
zstyle -L
print -r -- '--- functions ---'
functions skaffold cloudsql aws_profile_update hq _hq .autocomplete__down-line-or-select__zle-widget
'''
    env = dict(os.environ, HOME=str(home), TEST_FIXTURE=str(fixture), TEST_TRACE=str(trace))
    # Keep inherited custom paths from changing the expected baseline.
    for name in ("XDG_CACHE_HOME", "XDG_DATA_HOME", "AQUA_ROOT_DIR", "KREW_ROOT"):
        env.pop(name, None)
    result = subprocess.run(["/bin/zsh", "-f", "-c", command], env=env, text=True, capture_output=True)
    return result, trace.read_text()


class ShellTests(unittest.TestCase):
    def test_complete_startup_and_override_order(self):
        with tempfile.TemporaryDirectory(prefix="dotfiles-shell-") as directory:
            home = Path(directory) / "home with spaces"
            home.mkdir()
            prepare_shell_home(home)
            subprocess.run(
                ["bash", str(ROOT / "install.sh"), "--links-only"],
                env=dict(os.environ, HOME=str(home)), check=True, capture_output=True,
            )
            config = home / ".config/dotfiles"
            (config / "extra.zsh").write_text("trace extra\nexport TEST_OVERRIDE=extra\n")
            (config / "local.zsh").write_text("trace local\nexport TEST_OVERRIDE=local\n")
            # The prompt cache name depends on the OS account, not HOME.
            username = subprocess.check_output(
                ["/bin/zsh", "-f", "-c", "print -r -- ${(%):-%n}"], text=True,
            ).strip()
            (home / ".cache/p10k-instant-prompt-test.zsh").rename(
                home / f".cache/p10k-instant-prompt-{username}.zsh"
            )
            result, trace = shell_snapshot(home)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stderr, "")
            events = [line.split(" PATH=", 1)[0] for line in trace.splitlines()]
            self.assertEqual(events, [
                "instant-prompt", "zinit-source",
                "zinit light-mode for zdharma-continuum/zinit-annex-as-monitor zdharma-continuum/zinit-annex-bin-gem-node zdharma-continuum/zinit-annex-patch-dl zdharma-continuum/zinit-annex-rust",
                "zinit ice depth=1", "zinit light romkatv/powerlevel10k",
                "zinit light zsh-users/zsh-completions",
                'zinit ice depth=1 atload=!ZINIT[bkp-compdef]="${functions[compdef]}"; fpath+=( "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zasync" )',
                "zinit light marlonrichert/zsh-autocomplete",
                "zinit light zsh-users/zsh-autosuggestions",
                "zinit light zsh-users/zsh-syntax-highlighting",
                "direnv hook zsh", "zoxide init zsh", "sdkman", "mise activate zsh",
                "kubectl completion zsh", "compdef __start_kubectl k",
                "gcloud-path", "gcloud-completion", "fzf --zsh", "op",
                "compdef _hq hq", "extra", "local",
            ])
            for name in ("DIRENV", "ZOXIDE", "MISE", "FZF", "OP"):
                self.assertIn(f"TEST_{name}=loaded\n", result.stdout)
            self.assertIn("TEST_OVERRIDE=local\n", result.stdout)
            self.assertIn("POWERLEVEL9K_INSTANT_PROMPT=quiet\n", result.stdout)
            self.assertIn(f"HISTFILE={home}/.zhistory\n", result.stdout)
            self.assertIn("HISTSIZE=100000\nSAVEHIST=100000\n", result.stdout)
            self.assertIn("alias k=kubectl\n", result.stdout)
            for function in ("skaffold", "cloudsql", "aws_profile_update", "hq", "_hq"):
                self.assertIn(function + " () {", result.stdout)

            base = [str(home / ".local/bin")]
            base = [item for item in base if Path(item).is_dir()]
            base += [item for item in ("/opt/homebrew/bin", "/opt/homebrew/sbin") if Path(item).is_dir()]
            base += ["/usr/bin", "/usr/sbin", "/bin", "/sbin"]
            base += [item for item in ("/usr/local/bin", "/usr/local/sbin") if Path(item).is_dir()]
            base += ["/Library/Apple/usr/bin"]
            base = ["/opt/homebrew/opt/libpq/bin", *base]
            aqua = str(home / ".local/share/aquaproj-aqua/bin")
            initial = ":".join([aqua, *base])
            self.assertIn(f"direnv hook zsh PATH={initial}\n", trace)
            self.assertIn(f"zoxide init zsh PATH={initial}\n", trace)
            before_sdk = [
                str(home / ".cargo/bin"), "/opt/homebrew/opt/gpatch/libexec/gnubin",
                "/opt/homebrew/opt/gnu-sed/libexec/gnubin", str(home / ".krew/bin"),
                str(home / "commands"), aqua, *base, str(home / "flutter/bin"),
            ]
            self.assertIn("sdkman PATH=" + ":".join(before_sdk) + "\n", trace)
            final = [str(home / "Library/Android/sdk/cmdline-tools/latest/bin"),
                     str(home / "Library/Android/sdk/platform-tools"), str(home / "sdk/bin"), *before_sdk]
            self.assertIn("PATH=" + ":".join(final) + "\n", result.stdout)

    def test_integrations_allow_missing_optional_tools_and_settings(self):
        with tempfile.TemporaryDirectory(prefix="dotfiles-shell-fresh-") as directory:
            home = Path(directory) / "new home"
            home.mkdir()
            (home / ".zsh").symlink_to(ROOT / "shell/zsh", target_is_directory=True)
            command = r'''
compdef() { :; }
source "$HOME/.zsh/integrations.zsh"
(( $+functions[hq] && $+functions[skaffold] && $+functions[cloudsql] ))
'''
            result = subprocess.run(
                ["/bin/zsh", "-f", "-c", command],
                env=dict(os.environ, HOME=str(home), PATH="/usr/bin:/bin:/usr/sbin:/sbin"),
                text=True, capture_output=True,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stderr, "")


if __name__ == "__main__":
    unittest.main()

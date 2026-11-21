#!/bin/bash
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/scripts/link.sh"
links_only=false
ssh_config=""
zsh_config=""

usage() {
    printf 'Usage: bash install.sh [--links-only] [--extra-ssh-config FILE] [--extra-zsh-config FILE]\n'
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --links-only) links_only=true; shift ;;
        --extra-ssh-config|--extra-zsh-config)
            option="$1"
            if [ "$#" -lt 2 ] || [ -z "$2" ]; then
                usage >&2; exit 1
            fi
            if [ ! -f "$2" ] || [ ! -r "$2" ]; then
                printf 'Not a readable configuration file: %s\n' "$2" >&2
                exit 1
            fi
            # Resolve against the caller's directory, not the repository.
            file="$(resolve_file "$2")"
            if [ "$file" -ef "$SCRIPT_DIR/shell/zsh/zshrc" ] || [ "$file" -ef "$SCRIPT_DIR/apps/ssh/config" ]; then
                printf 'Specify a separate additional configuration file.\n' >&2
                exit 1
            fi
            case "$option" in
                --extra-ssh-config)
                    [ -z "$ssh_config" ] || { printf 'Duplicate --extra-ssh-config\n' >&2; exit 1; }
                    ssh_config="$file"
                    ;;
                --extra-zsh-config)
                    [ -z "$zsh_config" ] || { printf 'Duplicate --extra-zsh-config\n' >&2; exit 1; }
                    zsh_config="$file"
                    ;;
            esac
            shift 2
            ;;
        -h|--help) usage; exit 0 ;;
        *) usage >&2; exit 1 ;;
    esac
done

# Parse and validate all arguments before changing files or installing tools.
if [ "$(uname)" != "Darwin" ]; then
    printf 'This installer supports macOS only.\n' >&2
    exit 1
fi

if [ "$links_only" = false ]; then
    if [ "$(sysctl -in sysctl.proc_translated 2>/dev/null || true)" = "1" ]; then
        printf 'Run setup from a native Terminal.app session (disable Open using Rosetta).\n' >&2
        exit 1
    fi
    # Homebrew resets the sudo timestamp on every run, so cached credentials
    # never carry over between casks. sudo_local survives macOS updates.
    pam_tid='^auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so'
    if ! grep -Eq "$pam_tid" /etc/pam.d/sudo_local 2>/dev/null; then
        if [ ! -e /etc/pam.d/sudo_local ] || cmp -s /etc/pam.d/sudo_local /etc/pam.d/sudo_local.template; then
            sudo_local="$(mktemp)"
            sed -E 's/^#(auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so)/\1/' /etc/pam.d/sudo_local.template > "$sudo_local"
            if grep -Eq "$pam_tid" "$sudo_local"; then
                printf 'Enabling Touch ID for sudo.\n'
                sudo install -m 444 -o root -g wheel "$sudo_local" /etc/pam.d/sudo_local
            else
                printf 'Skipped Touch ID for sudo: unexpected /etc/pam.d/sudo_local.template.\n' >&2
            fi
            rm -f "$sudo_local"
        else
            printf 'Skipped Touch ID for sudo: /etc/pam.d/sudo_local has local changes.\n' >&2
        fi
    fi
    # An existing Homebrew may be missing from PATH in a new Terminal session.
    # Select the native prefix before deciding whether installation is needed.
    case "$(uname -m)" in
        arm64) brew_bin=/opt/homebrew/bin/brew ;;
        *) brew_bin=/usr/local/bin/brew ;;
    esac
    if [ ! -x "$brew_bin" ]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    eval "$("$brew_bin" shellenv)"
    if ! command -v git >/dev/null 2>&1; then
        brew install git
    fi
fi

bash "$SCRIPT_DIR/scripts/link-configs.sh"
if [ -n "$ssh_config" ]; then
    link_file "$ssh_config" "$HOME/.ssh/config.d/50-extra.conf"
fi
if [ -n "$zsh_config" ]; then
    link_file "$zsh_config" "$HOME/.config/dotfiles/extra.zsh"
fi

if [ "$links_only" = false ]; then
    bash "$SCRIPT_DIR/system/defaults.sh"
    bash "$SCRIPT_DIR/apps/editors/defaults.sh"
    bash "$SCRIPT_DIR/scripts/install-tools.sh"
    python3 "$SCRIPT_DIR/scripts/app-settings.py" apply
fi

printf 'Dotfiles installed. Open a new shell to load them.\n'

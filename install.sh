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
            if [ "$file" -ef "$SCRIPT_DIR/.zshrc" ] || [ "$file" -ef "$SCRIPT_DIR/mac/etc/.ssh/config" ]; then
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
if [ "$links_only" = false ]; then
    case "${OSTYPE}" in
        darwin*)
            if ! command -v brew >/dev/null 2>&1; then
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            if [ -x /opt/homebrew/bin/brew ]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            elif [ -x /usr/local/bin/brew ]; then
                eval "$(/usr/local/bin/brew shellenv)"
            fi
            if ! command -v git >/dev/null 2>&1; then
                brew install git
            fi
            ;;
        linux-gnu*)
            if ! command -v git >/dev/null 2>&1; then
                apt-get install -y git
            fi
            ;;
        *) printf 'Unsupported OS: %s\n' "$OSTYPE" >&2; exit 1 ;;
    esac
fi

bash "$SCRIPT_DIR/scripts/link-personal.sh"
if [ -n "$ssh_config" ]; then
    link_file "$ssh_config" "$HOME/.ssh/config.d/50-extra.conf"
fi
if [ -n "$zsh_config" ]; then
    link_file "$zsh_config" "$HOME/.config/dotfiles/extra.zsh"
fi

if [ "$links_only" = false ]; then
    case "${OSTYPE}" in
        darwin*)
            bash "$SCRIPT_DIR/mac/defaults.sh"
            bash "$SCRIPT_DIR/mac/brew.sh"
            bash "$SCRIPT_DIR/mac/link.sh"
            bash "$SCRIPT_DIR/mac/after_install.sh"
            ;;
        linux-gnu*)
            apt-get update
            xargs -a "$SCRIPT_DIR/linux/packages.txt" apt-get install -y
            ;;
    esac
fi

printf 'Dotfiles installed. Open a new shell to load them.\n'

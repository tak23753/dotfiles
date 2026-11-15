#!/bin/bash
set -eu

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$DOTFILES_DIR/scripts/link.sh"

if [ "$(uname)" != "Darwin" ]; then
    echo "Not macOS!"
    exit 1
fi

brew bundle --global

# Homebrew installs these outside Docker's default per-user plugin directory.
# Link individual plugins so existing credentials and other plugins are kept.
BREW_PREFIX="$(brew --prefix)"
for plugin in docker-compose docker-buildx; do
    link_file "$BREW_PREFIX/lib/docker/cli-plugins/$plugin" "$HOME/.docker/cli-plugins/$plugin"
done

# Preserve setup order: Homebrew, fonts, mise tools, then gcloud components.
mkdir -p "$HOME/Library/Fonts"
for font in "$DOTFILES_DIR"/system/fonts/*; do
    cp "$font" "$HOME/Library/Fonts/"
done

# Install globally configured tools independently of the caller's project.
mise --cd "$HOME" install
gcloud components install --quiet gke-gcloud-auth-plugin

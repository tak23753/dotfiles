#!/bin/bash
set -eu

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if [ "$(uname)" != "Darwin" ]; then
    echo "Not macOS!"
    exit 1
fi

brew bundle --global

# Preserve setup order: Homebrew, fonts, mise tools, then gcloud components.
mkdir -p "$HOME/Library/Fonts"
for font in "$DOTFILES_DIR"/system/fonts/*; do
    cp "$font" "$HOME/Library/Fonts/"
done

# Install globally configured tools independently of the caller's project.
mise --cd "$HOME" install
gcloud components install --quiet gke-gcloud-auth-plugin

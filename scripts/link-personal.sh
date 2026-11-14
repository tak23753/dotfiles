#!/bin/bash
set -eu

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$DOTFILES_DIR/scripts/link.sh"

# Explicit list: never link .git, local drafts, or future repository metadata.
for name in .Brewfile .p10k.zsh .terraformrc .zsh .zshrc; do
    link_file "$DOTFILES_DIR/$name" "$HOME/$name"
done

link_file "$DOTFILES_DIR/mac/etc/mise/config.toml" "$HOME/.config/mise/config.toml"

mkdir -p "$HOME/.ssh/config.d" "$HOME/.config/dotfiles" "$HOME/.terraform.d/plugin-cache"
chmod 700 "$HOME/.ssh" "$HOME/.ssh/config.d"
link_file "$DOTFILES_DIR/mac/etc/.ssh/config" "$HOME/.ssh/config"

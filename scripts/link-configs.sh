#!/bin/bash
set -eu

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
. "$DOTFILES_DIR/scripts/link.sh"

# Explicit source/destination mapping; repository layout is independent of HOME.
link_file "$DOTFILES_DIR/apps/homebrew/Brewfile" "$HOME/.Brewfile"
link_file "$DOTFILES_DIR/shell/zsh/p10k.zsh" "$HOME/.p10k.zsh"
link_file "$DOTFILES_DIR/apps/terraform/terraformrc" "$HOME/.terraformrc"
link_file "$DOTFILES_DIR/shell/zsh" "$HOME/.zsh"
link_file "$DOTFILES_DIR/shell/zsh/zshrc" "$HOME/.zshrc"

link_file "$DOTFILES_DIR/apps/mise/config.toml" "$HOME/.config/mise/config.toml"

mkdir -p "$HOME/.ssh/config.d" "$HOME/.config/dotfiles" "$HOME/.terraform.d/plugin-cache"
chmod 700 "$HOME/.ssh" "$HOME/.ssh/config.d"
link_file "$DOTFILES_DIR/apps/ssh/config" "$HOME/.ssh/config"

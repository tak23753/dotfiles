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
link_file "$DOTFILES_DIR/apps/git/config" "$HOME/.config/git/config"
link_file "$DOTFILES_DIR/apps/git/ignore" "$HOME/.config/git/ignore"
# Without ~/.gitconfig, `git config --global` writes through the link into this repository.
touch "$HOME/.gitconfig"

# Link the directory so an atomic save by LinearMouse keeps the link intact.
link_file "$DOTFILES_DIR/apps/linearmouse" "$HOME/.config/linearmouse"
link_file "$DOTFILES_DIR/apps/uv/uv.toml" "$HOME/.config/uv/uv.toml"
link_file "$DOTFILES_DIR/apps/cursor/settings.json" "$HOME/Library/Application Support/Cursor/User/settings.json"
# Use the native macOS location (confirmed with `k9s info`). Do not link the
# whole directory: k9s also stores logs, screen dumps and cluster state there.
for file in aliases.yaml plugins.yaml; do
    link_file "$DOTFILES_DIR/apps/k9s/$file" "$HOME/Library/Application Support/k9s/$file"
done
copy_file "$DOTFILES_DIR/apps/k9s/config.yaml" "$HOME/Library/Application Support/k9s/config.yaml"
copy_file "$DOTFILES_DIR/apps/colima/colima.yaml" "$HOME/.colima/default/colima.yaml"

mkdir -p "$HOME/.ssh/config.d" "$HOME/.config/dotfiles" "$HOME/.terraform.d/plugin-cache"
chmod 700 "$HOME/.ssh" "$HOME/.ssh/config.d"
link_file "$DOTFILES_DIR/apps/ssh/config" "$HOME/.ssh/config"

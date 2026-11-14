#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../scripts/link.sh"

# karabinerのキー設定
mkdir -p "$HOME/.config/karabiner/assets/complex_modifications"
for f in "${SCRIPT_DIR}"/etc/karabiner/* ; do
    link_file "$f" "$HOME/.config/karabiner/assets/complex_modifications/$(basename "$f")"
done
link_file "${SCRIPT_DIR}/etc/karabiner.json" "$HOME/.config/karabiner/karabiner.json"

# フォントの設定
mkdir -p "$HOME/Library/Fonts"
for f in "${SCRIPT_DIR}"/etc/fonts/* ; do
    cp "$f" "$HOME/Library/Fonts/"
done

# sshの設定
mkdir -p "$HOME/.ssh/config.d"
chmod 700 "$HOME/.ssh" "$HOME/.ssh/config.d"
link_file "${SCRIPT_DIR}/etc/.ssh/config" "$HOME/.ssh/config"

# Terraformのプラグインキャッシュの設定
mkdir -p "$HOME/.terraform.d/plugin-cache"

#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../scripts/link.sh"

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

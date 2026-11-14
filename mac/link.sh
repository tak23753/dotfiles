#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# フォントの設定
mkdir -p "$HOME/Library/Fonts"
for f in "${SCRIPT_DIR}"/etc/fonts/* ; do
    cp "$f" "$HOME/Library/Fonts/"
done

# Terraformのプラグインキャッシュの設定
mkdir -p "$HOME/.terraform.d/plugin-cache"

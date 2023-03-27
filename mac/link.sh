#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# karabinerのキー設定
mkdir -p "$HOME/.config/karabiner/assets/complex_modifications"
for f in "${SCRIPT_DIR}"/settings/karabiner/* ; do
    ln -fnsv "$f" "$HOME/.config/karabiner/assets/complex_modifications/"
done
ln -fnsv "${SCRIPT_DIR}/settings/karabiner.json" "$HOME/.config/karabiner/"

# フォントの設定
cp "${SCRIPT_DIR}/settings/MesloLGS NF Regular.ttf" "$HOME/Library/Fonts/"

# Google日本語入力の設定
# ln -fnsv "${SCRIPT_DIR}/settings/user_dictionary.db" "$HOME/Library/Application Support/Google/JapaneseInput/"

# awsの設定
mkdir -p "$HOME/.aws"
ln -fnsv "${SCRIPT_DIR}/settings/.aws/config" "$HOME/.aws/"

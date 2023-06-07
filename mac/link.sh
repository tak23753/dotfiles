#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# karabinerのキー設定
mkdir -p "$HOME/.config/karabiner/assets/complex_modifications"
for f in "${SCRIPT_DIR}"/etc/karabiner/* ; do
    ln -fnsv "$f" "$HOME/.config/karabiner/assets/complex_modifications/"
done
ln -fnsv "${SCRIPT_DIR}/etc/karabiner.json" "$HOME/.config/karabiner/"

# フォントの設定
for f in "${SCRIPT_DIR}"/etc/fonts/* ; do
    cp "$f" "$HOME/Library/Fonts/"
done
# cp "${SCRIPT_DIR}/etc/MesloLGS NF Regular.ttf" "$HOME/Library/Fonts/"

# Google日本語入力の設定
# ln -fnsv "${SCRIPT_DIR}/etc/user_dictionary.db" "$HOME/Library/Application Support/Google/JapaneseInput/"

# awsの設定
# mkdir -p "$HOME/.aws"
# cp -f "${SCRIPT_DIR}/etc/.aws/config" "$HOME/.aws/config"

# sshの設定
mkdir -p "$HOME/.ssh"
ln -fnsv "${SCRIPT_DIR}/etc/.ssh/config" "$HOME/.ssh/"

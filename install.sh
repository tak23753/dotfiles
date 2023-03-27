#!/bin/sh

set -eux

# gitをインストール
case "${OSTYPE}" in
    darwin*)
        # Install brew
        if !(type "brew" > /dev/null 2>&1); then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" > /dev/null
        fi

        # Install git
        if !(type "git" > /dev/null 2>&1); then
            brew install git
        fi
        ;;
    linux*)
        # Linux
        ;;
esac

# dotfilesをクローン
if [ basename $PWD != "dotfiles" && ! -d dotfiles ]; then
    git clone https://github.com/Fukiwake/dotfiles.git
    cd dotfiles
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# dotfilesのシンボリックリンクを作成
for dotfile in "${SCRIPT_DIR}"/.??* ; do
    [[ "$dotfile" == "${SCRIPT_DIR}/.git" ]] && continue
    [[ "$dotfile" == "${SCRIPT_DIR}/.github" ]] && continue
    [[ "$dotfile" == "${SCRIPT_DIR}/.DS_Store" ]] && continue

    ln -fnsv "$dotfile" "$HOME"
done

# OSごとの設定
case "${OSTYPE}" in
    darwin*)
        ${SCRIPT_DIR}/mac/init.sh
        ${SCRIPT_DIR}/mac/defaults.sh
        ${SCRIPT_DIR}/mac/brew.sh
        ${SCRIPT_DIR}/mac/link.sh
        ${SCRIPT_DIR}/mac/after_install.sh
        ;;
    linux*)
        # Linux
        ;;
esac

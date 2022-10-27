#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

for dotfile in "${SCRIPT_DIR}"/.??* ; do
    [[ "$dotfile" == "${SCRIPT_DIR}/.git" ]] && continue
    [[ "$dotfile" == "${SCRIPT_DIR}/.github" ]] && continue
    [[ "$dotfile" == "${SCRIPT_DIR}/.DS_Store" ]] && continue

    ln -fnsv "$dotfile" "$HOME"
done

case "${OSTYPE}" in
    darwin*)
        ${SCRIPT_DIR}/mac/init.sh
        ${SCRIPT_DIR}/mac/defaults.sh
        ${SCRIPT_DIR}/mac/brew.sh
        ${SCRIPT_DIR}/mac/link.sh
        ;;
    linux*)
        # Linux
        ;;
esac

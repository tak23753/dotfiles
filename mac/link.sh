#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

for f in "${SCRIPT_DIR}"/settings/karabiner/* ; do
    ln -fnsv "$f" "$HOME/.config/karabiner/assets/complex_modifications/"
done

ln -fnsv "${SCRIPT_DIR}/settings/com.lwouis.alt-tab-macos.plist" "$HOME/Library/Preferences/"

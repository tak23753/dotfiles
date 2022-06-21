#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

for f in "${SCRIPT_DIR}"/karabiner/* ; do
    ln -fnsv "$f" "$HOME/.config/karabiner/assets/complex_modifications/"
done

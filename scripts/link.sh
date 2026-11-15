#!/bin/bash

# Resolve file symlinks too, so passing an already-installed link cannot create
# a link that points to itself after the destination is replaced.
resolve_file() {
    local file="$1" target
    while :; do
        file="$(cd "$(dirname "$file")" && pwd -P)/$(basename "$file")"
        [ -L "$file" ] || break
        target="$(readlink "$file")"
        case "$target" in
            /*) file="$target" ;;
            *) file="$(dirname "$file")/$target" ;;
        esac
    done
    printf '%s\n' "$file"
}

# Existing files/directories and different symlinks are preserved before linking.
link_file() {
    local source="$1" destination="$2" backup
    mkdir -p "$(dirname "$destination")"
    if [ -L "$destination" ] && [ "$(readlink "$destination")" = "$source" ]; then
        return
    fi
    if [ -e "$destination" ] || [ -L "$destination" ]; then
        backup="$(mktemp -d "${destination}.backup.XXXXXX")"
        mv "$destination" "$backup/original"
        printf 'Backed up %s to %s/original\n' "$destination" "$backup"
    fi
    ln -s "$source" "$destination"
}

# Some applications replace their configuration files when saving. Give them a
# writable copy instead of a symlink, preserving the previous version on change.
copy_file() {
    local source="$1" destination="$2" backup
    mkdir -p "$(dirname "$destination")"
    if [ -f "$destination" ] && [ ! -L "$destination" ] && cmp -s "$source" "$destination"; then
        return
    fi
    if [ -e "$destination" ] || [ -L "$destination" ]; then
        backup="$(mktemp -d "${destination}.backup.XXXXXX")"
        mv "$destination" "$backup/original"
        printf 'Backed up %s to %s/original\n' "$destination" "$backup"
    fi
    cp "$source" "$destination"
}

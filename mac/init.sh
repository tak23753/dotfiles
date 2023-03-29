#!/bin/bash

set -eux

if [ "$(uname)" != "Darwin" ] ; then
	echo "Not macOS!"
	exit 1
fi


# Install xcode
# if !(type "xcode-select" > /dev/null 2>&1); then
# 	xcode-select --install > /dev/null
# fi

# Install rosetta
if !(type "arch" > /dev/null 2>&1); then
	softwareupdate --install-rosetta --agree-to-license
fi

# Install zinit
# bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

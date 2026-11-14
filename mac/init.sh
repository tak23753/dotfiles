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

# Install dein
mkdir -p ~/.vim/dein
# curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh
# curl https://raw.githubusercontent.com/Shougo/dein-installer.vim/master/installer.sh > installer.sh
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/Shougo/dein-installer.vim/master/installer.sh) ~/.vim/dein --overwrite-config"
# sh ./installer.sh --overwrite-config
# rm installer.sh

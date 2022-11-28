#!/bin/bash

set -ex

if [ "$(uname)" != "Darwin" ] ; then
	echo "Not macOS!"
	exit 1
fi


# Install xcode
if !(type "xcode-select" > /dev/null 2>&1); then
	xcode-select --install > /dev/null
fi

# Install brew
if !(type "brew" > /dev/null 2>&1); then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" > /dev/null
fi

# Install rosetta
sudo softwareupdate --install-rosetta

# Install zinit
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

# Install Session Manager
if !(type "session-manager-plugin" > /dev/null 2>&1); then
	curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/sessionmanager-bundle.zip" -o "sessionmanager-bundle.zip"
	unzip sessionmanager-bundle.zip
	sudo ./sessionmanager-bundle/install -i /usr/local/sessionmanagerplugin -b /usr/local/bin/session-manager-plugin
	rm -rf sessionmanager-bundle sessionmanager-bundle.zip
fi

# Install Finch
LOCATION=$(curl -s https://api.github.com/repos/runfinch/finch/releases/latest \
| grep "tag_name" \
| awk '{print "https://github.com/runfinch/finch/releases/download/" substr($2, 2, length($2)-3) "/Finch-" substr($2, 2, length($2)-3) "-aarch64.pkg" }')
curl $LOCATION -o /tmp/finch_installer.pkg
installer -pkg /tmp/finch_installer.pkg

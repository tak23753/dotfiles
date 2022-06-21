#!/bin/bash

set -ex

if [ "$(uname)" != "Darwin" ] ; then
	echo "Not macOS!"
	exit 1
fi

# ====================
#
# Track Pad
#
# ====================

# Tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# Tracking speed
defaults write -g com.apple.trackpad.scaling -int 3

# Key Repeat and Delay Until Repeat
defaults write -g InitialKeyRepeat -int 15
defaults write -g KeyRepeat -int 2

# ====================
#
# Dock & Menu bar
#
# ====================

# Automatically hide and show
defaults write com.apple.dock autohide -bool true

# Show quickly
defaults write com.apple.dock autohide-time-modifier -int 0

# Disable animation at application launch
defaults write com.apple.dock launchanim -bool false

# Do not display recent apps
defaults write com.apple.dock show-recents -bool false

# Show menu bar in full screen
# defaults write NSGlobalDomain AppleMenuBarVisibleInFullscreen -bool false

# ====================
#
# Finder
#
# ====================


# Disable animation
defaults write com.apple.finder DisableAllAnimations -bool true

# Show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show files with all extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Display the status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Display the path bar
defaults write com.apple.finder ShowPathbar -bool true

# ====================
#
# SystemUIServer
#
# ====================

# Display battery level in the menu bar
defaults write com.apple.menuextra.battery ShowPercent -string "YES"


for app in "Dock" \
	"Finder" \
	"SystemUIServer"; do
	killall "${app}" &> /dev/null
done


# sudo reboot

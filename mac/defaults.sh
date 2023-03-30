#!/bin/bash

set -ex

if [ "$(uname)" != "Darwin" ] ; then
	echo "Not macOS!"
	exit 1
fi

# ---------------------------------------------------------
# Preferences
# ---------------------------------------------------------

# ダークモードを有効化
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# ---------------------------------------------------------
# Track Pad
# ---------------------------------------------------------

# シングルタップでクリックする
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write -g com.apple.mouse.tapBehavior -bool true

# カーソル移動速度を速くする
defaults write -g com.apple.trackpad.scaling -int 3

# ---------------------------------------------------------
# Keyboard
# ---------------------------------------------------------

# キーリピートの反応速度を速くする
defaults write -g InitialKeyRepeat -int 12
defaults write -g KeyRepeat -int 1

# ---------------------------------------------------------
# Dock & Menu bar
# ---------------------------------------------------------

# 自動的に非表示にする
defaults write com.apple.dock autohide -bool true

# 表示スピードを速くする
defaults write com.apple.dock autohide-time-modifier -int 0

# アプリケーション起動時のアニメーションを無効化
defaults write com.apple.dock launchanim -bool false

# 最近起動したアプリを非表示
defaults write com.apple.dock show-recents -bool false

# メニューバーを常に表示
defaults write -g AppleMenuBarVisibleInFullscreen -bool true

# ---------------------------------------------------------
# Finder
# ---------------------------------------------------------

# アニメーション無効化
defaults write com.apple.finder DisableAllAnimations -bool true

# 隠しファイルを表示
defaults write com.apple.finder AppleShowAllFiles -bool true

# 拡張子を表示
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# ステータスバーを表示
defaults write com.apple.finder ShowStatusBar -bool true

# パスバーを表示
defaults write com.apple.finder ShowPathbar -bool true

# ---------------------------------------------------------
# Shortcut
# ---------------------------------------------------------

# Spotlightを無効化
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "<dict><key>enabled</key><false/></dict>"

# Finderを無効化
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 65 "<dict><key>enabled</key><false/></dict>"

# ---------------------------------------------------------
# Display
# ---------------------------------------------------------

# 視差効果を無効化
defaults write com.apple.Accessibility ReduceMotionEnabled -bool true

# ---------------------------------------------------------
# Activate
# ---------------------------------------------------------

for app in "Dock" \
	"Finder" \
	"SystemUIServer"; do
	killall "${app}" &> /dev/null
done

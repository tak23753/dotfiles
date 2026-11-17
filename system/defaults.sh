#!/bin/bash

set -eux

if [ "$(uname)" != "Darwin" ] ; then
	echo "Not macOS!"
	exit 1
fi

# 2026-11-15: macOS 26.5.2 / MacBook Pro (M2 Pro) の変更項目を反映。
# 日本語・日本地域で初期設定した新しいMacに、標準値からの変更だけを適用する。
# 既存Macの設定を標準値へ戻す処理は含めない。
# M5 Max を含む Apple Silicon Mac でも、機器IDを固定せず適用する。
# ディスプレイ配置・解像度・電源管理は移行先で設定する。
# Caps Lock は内蔵キーボードの機器IDを調べて Control に割り当てる。

# ---------------------------------------------------------
# Preferences
# ---------------------------------------------------------

# ダークモードを有効化
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# ---------------------------------------------------------
# Track Pad
# ---------------------------------------------------------

# 内蔵トラックパッド: フルスクリーンアプリ間の切り替えを4本指に限定
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 0

# 軌跡の速さ: 10段階の8段目（最大から2段下）
defaults write -g com.apple.trackpad.scaling -float 2

# ---------------------------------------------------------
# Mouse & Scroll
# ---------------------------------------------------------

# マウス速度を上げ、ポインタの加速を無効化
defaults write -g com.apple.mouse.scaling -float 1.5
defaults write -g com.apple.mouse.linear -bool true

# スクロール速度
defaults write -g com.apple.scrollwheel.scaling -float 1.7

# ---------------------------------------------------------
# Keyboard
# ---------------------------------------------------------

# キーリピートの反応速度を速くする
defaults write -g InitialKeyRepeat -int 15
defaults write -g KeyRepeat -int 2

# キーボード操作のモード
defaults write -g AppleKeyboardUIMode -int 1

# 日本語入力でWindows風のキー操作を有効にする
defaults write com.apple.inputmethod.Kotoeri JIMPrefWindowsModeKey -bool true

# 数字を全角入力を無効化
defaults write com.apple.inputmethod.Kotoeri JIMPrefFullWidthNumeralCharactersKey -bool false

# 文頭を自動的に大文字にするを無効化
defaults write -g NSAutomaticCapitalizationEnabled -bool false

# Caps Lock を Control にする
# システム設定 > キーボード > キーボードショートカット > 修飾キー
# 機器IDは機種で変わるので固定しない。VendorID と ProductID がどちらも 0 の
# 内蔵キーボードでは、hidutil の matching に 0 を渡すと全デバイスへ当たる。
caps_lock_to_control='<dict><key>HIDKeyboardModifierMappingSrc</key><integer>30064771129</integer><key>HIDKeyboardModifierMappingDst</key><integer>30064771296</integer></dict>'
builtin_keyboards=0
while IFS= read -r keyboard; do
	case "$keyboard" in
	*'"type":"service"'*'"Built-In":true'*|*'"Built-In":true'*'"type":"service"'*) ;;
	*) continue ;;
	esac
	vendor=$(printf '%s\n' "$keyboard" | sed -n 's/.*"VendorID" *: *\([0-9][0-9]*\).*/\1/p')
	product=$(printf '%s\n' "$keyboard" | sed -n 's/.*"ProductID" *: *\([0-9][0-9]*\).*/\1/p')
	product_name=$(printf '%s\n' "$keyboard" | sed -n 's/.*"Product" *: *"\([^"]*\)".*/\1/p')
	if [ -z "$vendor" ] || [ -z "$product" ] || [ -z "$product_name" ]; then
		continue
	fi
	defaults -currentHost write -g "com.apple.keyboard.modifiermapping.${vendor}-${product}-0" -array "$caps_lock_to_control"
	if [ "$vendor" = 0 ] && [ "$product" = 0 ]; then
		keyboard_match='{"PrimaryUsagePage":1,"PrimaryUsage":6,"Product":"'"$product_name"'"}'
	else
		keyboard_match=$(printf '{"PrimaryUsagePage":1,"PrimaryUsage":6,"VendorID":%s,"ProductID":%s}' "$vendor" "$product")
	fi
	hidutil property --matching "$keyboard_match" --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":30064771129,"HIDKeyboardModifierMappingDst":30064771296}]}' >/dev/null
	builtin_keyboards=$((builtin_keyboards + 1))
done < <(hidutil list --ndjson --matching '{"PrimaryUsagePage":1,"PrimaryUsage":6}')
if [ "$builtin_keyboards" -eq 0 ]; then
	echo "内蔵キーボードが見つからないため、Caps Lock を変更できません" >&2
	exit 1
fi

# ---------------------------------------------------------
# Dock & Menu bar
# ---------------------------------------------------------

# 自動的に非表示にする
defaults write com.apple.dock autohide -bool true

# 表示スピードを速くする
defaults write com.apple.dock autohide-time-modifier -float 0

# アプリケーション起動時のアニメーションを無効化
defaults write com.apple.dock launchanim -bool false

# 最近起動したアプリを非表示
defaults write com.apple.dock show-recents -bool false

# ピン留めしたアプリとフォルダを外す（Finder とゴミ箱は残る）
# install.sh を再実行すると、あとから追加した項目も外れる
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock persistent-others -array

# メニューバーを常に表示
defaults write -g AppleMenuBarVisibleInFullscreen -bool true

# Bluetoothをメニューバーに表示（現在の保存先）
defaults -currentHost write com.apple.controlcenter Bluetooth -int 2

# 時計に秒を表示
defaults write com.apple.menuextra.clock ShowSeconds -bool true

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

# デフォルトはリスト表示
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# ---------------------------------------------------------
# Shortcut
# ---------------------------------------------------------

# Spotlightの検索（64: 検索、65: Finderの検索ウインドウ）を無効化
for hotkey in 64 65; do
	defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$hotkey" "<dict><key>enabled</key><false/></dict>"
done

# クイックメモのショートカットをoption+qに変更
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 190 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>113</integer><integer>12</integer><integer>524288</integer></array><key>type</key><string>standard</string></dict></dict>"

# ---------------------------------------------------------
# Screen Saver
# ---------------------------------------------------------

# スクリーンセーバ開始まで1時間（ホストUUIDを固定せず、移行先に保存）
defaults -currentHost write com.apple.screensaver idleTime -int 3600

# ---------------------------------------------------------
# Screen Capture
# ---------------------------------------------------------

# 画面収録中のマウスクリックを表示
defaults write com.apple.screencapture showsClicks -bool true

# ---------------------------------------------------------
# Activate
# ---------------------------------------------------------

for app in "Dock" \
	"Finder" \
	"SystemUIServer"; do
	killall "${app}" &> /dev/null || true
done

echo "macOS preferences updated. Log out and back in to apply all keyboard/trackpad settings."

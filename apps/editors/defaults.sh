#!/bin/bash
set -ex

# ---------------------------------------------------------
# Vim
# ---------------------------------------------------------
defaults write com.todesktop.230313mzl4w4u92 ApplePressAndHoldEnabled -bool false

defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false              # For VS Code
defaults write com.microsoft.VSCodeInsiders ApplePressAndHoldEnabled -bool false      # For VS Code Insider
defaults write com.vscodium ApplePressAndHoldEnabled -bool false                      # For VS Codium
defaults write com.microsoft.VSCodeExploration ApplePressAndHoldEnabled -bool false   # For VS Codium Exploration users
defaults write com.exafunction.windsurf ApplePressAndHoldEnabled -bool false          # For Windsurf
if defaults read -g ApplePressAndHoldEnabled >/dev/null 2>&1; then
  defaults delete -g ApplePressAndHoldEnabled
fi

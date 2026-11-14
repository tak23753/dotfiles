# Additional settings interface v1: linked by install.sh --extra-zsh-config.
# local.zsh is optional, machine-specific, and never managed by either installer.
for config in "$HOME/.config/dotfiles/extra.zsh" "$HOME/.config/dotfiles/local.zsh"; do
  if [[ -r "$config" ]]; then
    source "$config"
  fi
done
unset config

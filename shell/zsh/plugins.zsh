# ---------------------------------------------------------
# Zinit's Installer
# ---------------------------------------------------------

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Remove zi alias created by zinit
unalias zi 2>/dev/null

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

# ---------------------------------------------------------
# Plugin
# ---------------------------------------------------------

zinit ice depth=1
zinit light romkatv/powerlevel10k
zinit light zsh-users/zsh-completions
zinit ice depth=1 atload='!ZINIT[bkp-compdef]="${functions[compdef]}"; fpath+=( "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zasync" )'
zinit light marlonrichert/zsh-autocomplete
# 上下矢印キーでの履歴移動を通常の Zsh の挙動に戻す（zsh-autocomplete の履歴メニューを無効化）
zstyle -e ':autocomplete:*(up|down)-line-or-history*:' ignore 'zasync cancel wait; zasync cancel complete; builtin zle -Rc; reply=( yes )'
.autocomplete__down-line-or-select__zle-widget() {
  if (( HISTNO < HISTCMD )) || [[ -z $BUFFER ]]; then
    builtin zle down-line-or-history -w
  elif [[ $RBUFFER == *$'\n'* ]]; then
    builtin zle down-line
  else
    builtin zle menu-select -w
  fi
}
bindkey -M emacs \
    '^P'   up-line-or-history \
    '^[OA' up-line-or-history \
    '^[[A' up-line-or-history
bindkey -M vicmd \
    '^P'   up-history \
    'k'    up-line-or-history \
    '^[OA' up-line-or-history \
    '^[[A' up-line-or-history
zinit light zsh-users/zsh-autosuggestions
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=( down-line-or-select )
zinit light zsh-users/zsh-syntax-highlighting
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

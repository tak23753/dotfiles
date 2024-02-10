# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ---------------------------------------------------------
# Aliases
# ---------------------------------------------------------

# Terraform
alias tf="terraform"
alias tg="terragrunt"

# Git
alias g='git'
alias ga='git add -A'
alias gc='git commit'
alias gps='git push'
alias gpl='git pull'

# Kubernetes
[ -f ~/.kubectl_aliases ] && source ~/.kubectl_aliases
# function kubectl() { echo "+ kubectl $@">&2; command kubectl $@; }

alias kc="kubie ctx"
alias kn="kubie ns"

# ---------------------------------------------------------
# Base settings
# ---------------------------------------------------------

# ヒストリ (履歴) を保存、数を増やす
HISTFILE=~/.zhistory
HISTSIZE=100000
SAVEHIST=100000

# 同時に起動した zsh の間でヒストリを共有する
setopt inc_append_history
setopt share_history

# 直前と同じコマンドの場合はヒストリに追加しない
setopt hist_ignore_dups

# 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups

# スペースから始まるコマンド行はヒストリに残さない
setopt hist_ignore_space

# ヒストリに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks

# 補完を有効化
autoload -Uz compinit && compinit

# 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# 補完候補をTabや矢印で選択可能
zstyle ':completion:*:default' menu select=1

# コマンドのスペルを訂正する
setopt correct

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
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light mollifier/anyframe
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# ---------------------------------------------------------
# Anyframe
# ---------------------------------------------------------

bindkey '^r' anyframe-widget-execute-history
bindkey '^b' anyframe-widget-checkout-git-branch
bindkey '^t' anyframe-widget-cdr
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

# ---------------------------------------------------------
# Import zsh files
# ---------------------------------------------------------
case ${OSTYPE} in
    darwin*)
    ZSH_DIR="${HOME}/.zsh/mac"
    ;;
    linux*)
    ZSH_DIR="${HOME}/.zsh/linux"
    ;;
esac

# ZSH_DIRがディレクトリで、読み取り、実行、が可能なとき
if [ -d $ZSH_DIR ] && [ -r $ZSH_DIR ] && [ -x $ZSH_DIR ]; then
    # zshディレクトリより下にある、.zshファイルの分、繰り返す
    for file in ${ZSH_DIR}/**/*.zsh; do
        # 読み取り可能ならば実行する
        [ -r $file ] && source $file
    done
fi

# ---------------------------------------------------------
# Others
# ---------------------------------------------------------

# aqua
export PATH="${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin:$PATH"

# direnv
if type "direnv" > /dev/null 2>&1; then
    eval "$(direnv hook zsh 2> /dev/null)"
fi

# volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# custom commands
export PATH="$HOME/commands:$PATH"

# krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Github Copilot Cli
if (type "github-copilot-cli" > /dev/null 2>&1); then
    eval "$(github-copilot-cli alias -- "$0")"
fi

# awsp
alias awsp=aws_profile_update
function aws_profile_update() {
    PROFILES=$(aws configure list-profiles)
    PROFILES_ARRAY=($(echo $PROFILES))
    SELECTED_PROFILE=$(echo $PROFILES | peco)

    [[ -n ${PROFILES_ARRAY[(re)${SELECTED_PROFILE}]} ]] && export AWS_PROFILE=${SELECTED_PROFILE}; echo 'Updated profile' || echo ''
}

# asdf
if (type "asdf" > /dev/null 2>&1); then
    . /opt/homebrew/opt/asdf/libexec/asdf.sh
fi

# kubectl
if (type "kubectl" > /dev/null 2>&1); then
    source <(kubectl completion zsh)
    alias k=kubectl
    compdef __start_kubectl k
fi

# gcloud
if (type "gcloud" > /dev/null 2>&1); then
    source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
    source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
fi

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"

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
alias t="terraform"

# Git
alias g='git'

# Kubernetes
# [ -f ~/.kubectl_aliases ] && source ~/.kubectl_aliases
# function kubectl() { echo "+ kubectl $@">&2; command kubectl $@; }
alias n="kubectl neat"
alias nl="kubectl neat | less"

alias kc="kubie ctx"
alias kn="kubie ns"

alias vim="nvim"
alias vi="nvim"

# Others
alias sops="EDITOR='cursor --wait' sops"
alias ll='ls -al'
alias date='gdate'
alias c='env -u ZDOTDIR cursor'

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

# ヒストリに時刻を保存する
setopt extended_history

# 補完を有効化 (zsh-autocomplete 側で初期化されるため無効化)
# autoload -Uz compinit && compinit

# 補完で小文字でも大文字にマッチさせる
# zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# 補完候補をTabや矢印で選択可能
# zstyle ':completion:*:default' menu select=1

# コマンドのスペルを訂正する
# setopt correct

# 英数字以外を区切り文字にする
typeset -g WORDCHARS=

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
zinit light mollifier/anyframe
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# ---------------------------------------------------------
# Anyframe
# ---------------------------------------------------------

# bindkey '^r' anyframe-widget-put-history
# bindkey '^b' anyframe-widget-checkout-git-branch
# bindkey '^t' anyframe-widget-cdr
# autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
# add-zsh-hook chpwd chpwd_recent_dirs

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

# zoxide
eval "$(zoxide init zsh)"

# custom commands
export PATH="$HOME/commands:$PATH"

# krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# gnu-sed
PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"

# gpatch
PATH="/opt/homebrew/opt/gpatch/libexec/gnubin:$PATH"

# go
export GOPATH=$HOME/.go

# flutter
export PATH="$PATH:$HOME/flutter/bin"
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export ANDROID_HOME="$HOME/Library/Android/sdk"

# rust
export PATH="$HOME/.cargo/bin:$PATH"

# claude auto mode
export CLAUDE_CODE_ENABLE_AUTO_MODE=1

# sdkman
source "$HOME/.sdkman/bin/sdkman-init.sh"

# android sdk tools in PATH
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"

# skaffold
skaffold() {
  # 実行しようとしているサブコマンドを取得
  local sub_cmd="$1"

  # dev, run, debug など、デプロイを伴う操作のみチェック対象にする
  if [[ "$sub_cmd" == "dev" || "$sub_cmd" == "run" || "$sub_cmd" == "debug" ]]; then

    # 現在のコンテキストの API サーバーのURLを取得
    local cluster_url=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
    local current_ctx=$(kubectl config current-context)

    # 「localhost」や「127.0.0.1」を含まない場合は警告して中断
    # ※ minikubeやDocker Desktop, kindなどは通常ここがローカルIPになります
    if [[ ! "$cluster_url" =~ "localhost" && ! "$cluster_url" =~ "127.0.0.1" && ! "$cluster_url" =~ "::1" ]]; then
      echo "現在のコンテキスト '$current_ctx' はローカルクラスタではないようです。"
      echo "API Server: $cluster_url"
      echo "本番・共有環境への誤爆防止のため、実行を中止しました。"
      return 1
    fi
  fi

  # 安全が確認されたか、チェック対象外のコマンドなら本物の skaffold を実行
  command skaffold "$@"
}

# cloudsql: `connect --direct` のときだけ psql の代わりに pgcli を使う薄いラッパー。
# cloudsql は psql を PATH 経由で `bash -c` 起動するため、その回だけ psql シムを
# PATH 先頭に差し込んで pgcli にすり替える。それ以外は素通し（オプションもそのまま）。
cloudsql() {
  if [[ "$1" == "connect" && " $* " == *" --direct "* ]] && command -v pgcli >/dev/null; then
    local shim; shim="$(mktemp -d)"
    cat >"$shim/psql" <<'EOF'
#!/usr/bin/env bash
exec pgcli "$@"
EOF
    chmod +x "$shim/psql"
    PATH="$shim:$PATH" command cloudsql "$@"
    local rc=$?
    rm -rf "$shim"
    return $rc
  fi
  command cloudsql "$@"
}

# Github Copilot Cli
if (type "github-copilot-cli" > /dev/null 2>&1); then
    eval "$(github-copilot-cli alias -- "$0")"
fi

# history
setopt extended_history
alias history='history -t "%F %T"'

# awsp
alias awsp=aws_profile_update
function aws_profile_update() {
    PROFILES=$(aws configure list-profiles)
    PROFILES_ARRAY=($(echo $PROFILES))
    SELECTED_PROFILE=$(echo $PROFILES | fzf)

    [[ -n ${PROFILES_ARRAY[(re)${SELECTED_PROFILE}]} ]] && export AWS_PROFILE=${SELECTED_PROFILE}; echo 'Updated profile' || echo ''
}

eval "$("$HOME/.local/bin/mise" activate zsh)"

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

# fzf
source <(fzf --zsh)

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

# . /opt/homebrew/opt/asdf/libexec/asdf.sh

# . /opt/homebrew/opt/asdf/libexec/asdf.sh

source /Users/takashi.fukiwake/.config/op/plugins.sh

# Harlequin ラッパー: harlequin の引数をそのまま受け取り、対象プロファイルが
# proxy 対応表にあれば cloud-sql-proxy を自動起動/停止する。
# -P/--profile を見て判定し、未指定なら default_profile を採用。
# 使い方:  hq                 -> default_profile で起動
#          hq -P company      -> cloud-sql-proxy を自動起動して起動
#          hq -a sqlite a.db  -> harlequin の任意オプションがそのまま通る
# proxy 対応表: ~/.harlequin-proxies.conf / プロファイル定義: ~/.harlequin.toml
hq() {
  local conf="$HOME/.harlequin-proxies.conf"
  local toml="$HOME/.harlequin.toml"

  # 引数から profile を検出 (-P NAME / --profile NAME / --profile=NAME / -PNAME)
  local profile="" i
  local -a args=("$@")
  for (( i=1; i<=$#args; i++ )); do
    case "${args[i]}" in
      -P|--profile) profile="${args[i+1]}" ;;
      --profile=*)  profile="${args[i]#--profile=}" ;;
      -P?*)         profile="${args[i]#-P}" ;;
    esac
  done
  # -P 未指定なら default_profile を採用
  if [[ -z "$profile" ]]; then
    profile=$(grep -E '^[[:space:]]*default_profile[[:space:]]*=' "$toml" 2>/dev/null \
      | head -1 | sed -E 's/.*=[[:space:]]*"?([^"#]+)"?.*/\1/' | tr -d '[:space:]')
  fi

  # profile が proxy 対応表になければ、そのまま harlequin へ委譲
  local instance=""
  [[ -n "$profile" && -f "$conf" ]] && \
    instance=$(grep -E "^[[:space:]]*${profile}=" "$conf" | grep -v '^[[:space:]]*#' | head -1 | cut -d= -f2-)
  if [[ -z "$instance" ]]; then
    harlequin "$@"
    return
  fi

  # 空きポートを動的取得 → proxy 起動 → ポート待機 → 起動(-p でポート注入) → 終了時に停止
  local port
  port=$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()')
  cloud-sql-proxy --auto-iam-authn --private-ip --port "$port" "$instance" &
  local pid=$!
  trap 'kill $pid 2>/dev/null' EXIT INT TERM
  for (( i=1; i<=30; i++ )); do nc -z 127.0.0.1 "$port" 2>/dev/null && break; sleep 0.3; done
  harlequin "$@" -p "$port"
  kill $pid 2>/dev/null
  trap - EXIT INT TERM
}

# 補完: -P/--profile の後はプロファイル名、それ以外はファイル
_hq() {
  local -a profiles
  profiles=(${(f)"$(grep -oE '^\[profiles\.[^]]+\]' "$HOME/.harlequin.toml" 2>/dev/null | sed -E 's/^\[profiles\.(.+)\]$/\1/')"})
  if [[ "${words[CURRENT-1]}" == (-P|--profile) ]]; then
    compadd -- $profiles
  else
    _files
  fi
}
compdef _hq hq

# Optional work and per-machine settings (interface owned by personal dotfiles).
source "$HOME/.zsh/additional-settings.zsh"

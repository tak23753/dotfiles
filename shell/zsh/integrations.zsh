# Keep tool setup and function loading in their original order.
# Tool-specific PATH changes stay beside their initialization.

# aqua
export PATH="${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin:$PATH"

# direnv
if type "direnv" > /dev/null 2>&1; then
    eval "$(direnv hook zsh 2> /dev/null)"
fi

# zoxide
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

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

# sdkman
if [[ -r "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# android sdk tools in PATH
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"


source "$HOME/.zsh/functions/kubernetes.zsh"
source "$HOME/.zsh/functions/cloudsql.zsh"

# history
alias history='history -t "%F %T"'

source "$HOME/.zsh/functions/aws.zsh"

if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate zsh)"
fi

# kubectl
if (type "kubectl" > /dev/null 2>&1); then
    source <(kubectl completion zsh)
    alias k=kubectl
    compdef __start_kubectl k
fi

# gcloud
if command -v gcloud >/dev/null 2>&1 && command -v brew >/dev/null 2>&1; then
    for gcloud_init in "$(brew --prefix)/share/google-cloud-sdk/"{path,completion}.zsh.inc; do
        [[ ! -r "$gcloud_init" ]] || source "$gcloud_init"
    done
    unset gcloud_init
fi

# fzf
if command -v fzf >/dev/null 2>&1; then
    source <(fzf --zsh)
fi

# Created by `op plugin init`; it does not exist on a fresh Mac.
if [[ -r "$HOME/.config/op/plugins.sh" ]]; then
    source "$HOME/.config/op/plugins.sh"
fi

source "$HOME/.zsh/functions/harlequin.zsh"

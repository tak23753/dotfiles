# Keep tool setup and function loading in their original order.
# Tool-specific PATH changes stay beside their initialization.

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

# sdkman
source "$HOME/.sdkman/bin/sdkman-init.sh"

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
if (type "gcloud" > /dev/null 2>&1); then
    source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
    source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
fi

# fzf
source <(fzf --zsh)

source /Users/takashi.fukiwake/.config/op/plugins.sh

source "$HOME/.zsh/functions/harlequin.zsh"

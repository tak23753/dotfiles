# Isolate startup from installed tools, plugin downloads, and personal settings.
trace() {
  print -r -- "$*" >> "$TEST_TRACE"
}

typeset -gA _comps ZINIT
zinit() { trace "zinit $*"; }
compdef() { trace "compdef $*"; }
direnv() {
  trace "direnv $* PATH=$PATH"
  print -r -- 'export TEST_DIRENV=loaded'
}
zoxide() {
  trace "zoxide $* PATH=$PATH"
  print -r -- 'export TEST_ZOXIDE=loaded'
}
mise() {
  trace "mise $* PATH=$PATH"
  print -r -- 'export TEST_MISE=loaded'
}
kubectl() {
  trace "kubectl $*"
  print -r -- '__start_kubectl() { :; }'
}
gcloud() { :; }
brew() { print -r -- "$HOME/brew"; }
fzf() {
  trace "fzf $*"
  print -r -- 'export TEST_FZF=loaded'
}

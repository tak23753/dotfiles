#!/bin/bash
set -eu

# Install only missing runtimes/tools; repeated runs preserve existing versions.
if ! command -v node >/dev/null 2>&1; then
  volta install node
fi
if ! command -v npm >/dev/null 2>&1; then
  volta install npm
fi

# setting git commit template
# git config --global commit.template ~/.gitmessage

# Install kubectl_aliases
if [ ! -f ~/.kubectl_aliases ]; then
  curl -fSL "https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases" -o ~/.kubectl_aliases
fi

# Install gcloud plugins
gcloud components install --quiet gke-gcloud-auth-plugin anthos-auth

# kubectl/kubectx are managed in .Brewfile, avoiding repeated asdf registration.

#!/bin/bash
set -eu

# Install kubectl_aliases
if [ ! -f ~/.kubectl_aliases ]; then
  curl -fSL "https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases" -o ~/.kubectl_aliases
fi

# Install gcloud plugins
gcloud components install --quiet gke-gcloud-auth-plugin anthos-auth

# kubectl/kubectx are managed in .Brewfile, avoiding repeated asdf registration.

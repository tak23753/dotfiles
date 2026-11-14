#!/bin/bash
set -eu

# Install gcloud plugins
gcloud components install --quiet gke-gcloud-auth-plugin anthos-auth

# kubectl/kubectx are managed in .Brewfile, avoiding repeated asdf registration.

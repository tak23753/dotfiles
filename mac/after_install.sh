#!/bin/bash
set -eu

# Install gcloud plugins
gcloud components install --quiet gke-gcloud-auth-plugin

# kubectl/kubectx are managed in .Brewfile, avoiding repeated asdf registration.

#!/bin/bash
set -eu

# Install globally configured tools with mise, independent of the caller's project.
mise --cd "$HOME" install

# Install gcloud plugins
gcloud components install --quiet gke-gcloud-auth-plugin

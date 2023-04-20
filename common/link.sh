#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# awsの設定
mkdir -p "$HOME/.aws"
ln -fnsv "${SCRIPT_DIR}/etc/.aws/config" "$HOME/.aws/"

#!/usr/bin/env bash
set -euo pipefail

KUBECONFORM_VERSION=0.7.0

curl -fsSL "https://github.com/yannh/kubeconform/releases/download/v${KUBECONFORM_VERSION}/kubeconform-linux-$(dpkg --print-architecture).tar.gz" \
  | tar -xz -C /usr/local/bin kubeconform
pip install --no-cache-dir pre-commit
pre-commit install

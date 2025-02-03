#!/bin/bash
set -euxo pipefail

sudo apt-get update
sudo apt-get install -y \
  libnss3 nss-plugin-pem ca-certificates \
  python3 python3-venv python3-pip

#!/usr/bin/env bash
set -euo pipefail

IFS=$'\n\t'

if command -v bats &>/dev/null; then
    echo "bats is existing"
    exit 0
fi

echo "Installing bats"
git clone https://github.com/sstephenson/bats.git ./ci-tmp/bats-install
cd ./ci-tmp/bats-install
sudo ./install.sh /usr/local

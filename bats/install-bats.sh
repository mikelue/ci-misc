#!/usr/bin/env sh
set -eu

if command -v bats >/dev/null 2>&1; then
    echo "bats is existing"
    exit 0
fi

echo "Installing bats"
git clone https://github.com/bats-core/bats-core.git ./ci-tmp/bats-install
cd ./ci-tmp/bats-install
sudo ./install.sh /usr/local

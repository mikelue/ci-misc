#!/usr/bin/env sh
set -eu

if command -v bats >/dev/null 2>&1; then
	echo "bats is existing"
	exit 0
fi

echo "Installing bats-core"
git clone --depth 1 https://github.com/bats-core/bats-core.git ./ci-tmp/bats-install
cd ./ci-tmp/bats-install
./install.sh /usr/local

echo "Installing bash_shell_mock"
git clone --depth 1 https://github.com/capitalone/bash_shell_mock ./ci-tmp/bash_shell_mock
cd ./ci-tmp/bash_shell_mock
./install.sh /usr/local

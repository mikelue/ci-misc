#!/usr/bin/env sh

set -ue

python3 --version
echo "cassandra-migrate $(pip3 show cassandra-migrate | grep 'Version')"
echo "cassandra-driver $(pip3 show cassandra-driver | grep 'Version')"
echo -e "\n"

exec "$@"

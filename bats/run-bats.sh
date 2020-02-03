#!/usr/bin/env sh
set -eu

if [ $# -eq 0 ]; then
	>&2 echo "Usage: run-bats.sh <bats directory>"
	exit 1
fi

test_folder=$1

echo "Checks bats file in folder: \"$test_folder\""
for batfile in $test_folder/*.bats; do
	if [ -x $batfile ]; then
		echo "Running bats file: \"$(basename $batfile)\""
		bats --tap $batfile
	fi
done

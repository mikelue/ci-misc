#!/usr/bin/env bash
set -euo pipefail

test_folder=$1

echo "Checks bats file in folder: \"$test_folder\""
for batfile in $1/*.bats; do
	if [[ -x $batfile ]]; then
		echo "Running bats file: \"$(basename $batfile)\""
		$batfile
	fi
done

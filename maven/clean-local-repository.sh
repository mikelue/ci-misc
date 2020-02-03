#!/usr/bin/env sh

set -eu

if [ $# -eq 0 ]; then
	>&2 echo "Usage: clean-local-repository.sh <.m2 root>"
	exit 1
fi

local_repos="$1/repository"
temp_list="/tmp/clean.maven.list"

# The days(at least) of artifacts which are not accessed
last_atime="+90"

if [ ! -d "$local_repos" ]; then
	echo "No repository folder: \"$local_repos.\" Exit."
	exit 0
fi

echo "Clean local repos: \"$local_repos\""

# Removes un-used(over 60 days) directories of artifacts
find "$local_repos" -atime $last_atime -type f -name "*.pom" -printf '%h\n' >$temp_list
xargs -n 32 -a $temp_list rm -rf
echo Remove [$(wc -l <$temp_list)] folders of artifacts

# Removes empty directories
find "$local_repos" -type d -empty -delete

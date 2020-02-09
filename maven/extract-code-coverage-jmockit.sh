#!/usr/bin/env sh

set -ue

usage()
{
    echo "Usage:"
    echo "extract-code-coverage-jmockit.sh <maven project root>"
} >&2

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

coverage_file="$1/target/coverage-report/index.html"
if [ ! -f "$coverage_file" ]; then
    >&2 echo Coverage file is not existing: \"$coverage_file\"
    usage
    exit 1
fi

script_dir=$(dirname "$0")

exec sed -nEf $script_dir/extract-code-coverage-jmockit.sed "$1/target/coverage-report/index.html"

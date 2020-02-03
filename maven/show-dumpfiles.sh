#!/usr/bin/env sh

set -eu

if [ $# -eq 0 ]; then
	>&2 echo "Usage: show-dumpfiles.sh <maven project root>"
	exit 1
fi

mvn_project_folder="$1"

if [ ! -d $mvn_project_folder ]; then
    >&2 echo "Non-existing folder for \"$mvn_project_folder\""
    exit 1
fi

mvn_project_folder=$(basename "$mvn_project_folder")

show_dumps()
{
    plugin=$1
    plugin_report_folder="$mvn_project_folder/target/$plugin-reports"

    if [ -d $plugin_report_folder ]; then
        dumpfiles=$(find "$plugin_report_folder" -type f -and \( -name '*.dumpstream' -or -name '*.dump' \))

        for dump_file in $dumpfiles; do
            echo "\n>>>>> Dump file[$plugin]: \"$(basename $dump_file)\""
            cat $dump_file
            echo "<<<<<-:"
        done
    fi
}

show_dumps "surefire"
show_dumps "failsafe"

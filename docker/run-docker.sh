#!/usr/bin/env sh
set -eu

usage()
{
	echo "Usage: "
	echo "run-docker.sh [-d <docker options>] [-w <workdir>] [-v] <image> [commands ...]"
} >&2

docker_options=""
host_work_dir=""
verbose=0

verbose_output()
{
	if [ $verbose -eq 0 ]; then
		return 0
	fi

	echo "$1"
}

while getopts "vd:w:" opt; do
	case $opt in
	d)
		docker_options="$OPTARG"
		;;
	w)
		host_work_dir="$OPTARG"
		;;
	v)
		verbose=1
		;;
	\?)
		usage
		exit 1
		;;
	esac
done
shift $(($OPTIND-1))

if [ $# -lt 1 ]; then
	usage
	exit 1
fi

image=$1
shift 1

verbose_output "Running docker[$image]"

if [ $# -ge 1 ]; then
	verbose_output "\tstart command: \"$1\""
fi

mount_work_dir=""
if [ -n "$host_work_dir" ]; then
	verbose_output "\tWork directory from host: \"$host_work_dir\""
	mount_work_dir="-v '$host_work_dir:/workdir'"
fi

if ! docker pull -q "$image"; then
	echo "Pull image '$image' has failed."
	exit 1
fi

eval exec docker run $docker_options $mount_work_dir --rm --workdir=/workdir "$image" "$@"

#!/usr/bin/env sh
set -eu

usage()
{
	echo "Usage: "
	echo "run-docker.sh [ -d <docker options> ] <image> <host work dir> [commands ...]"
} >&2

docker_options=""
while getopts ":d:" opt; do
	case $opt in
	d)
		docker_options="$OPTARG"
		;;
	\?)
		usage
		exit 1
		;;
	esac
done
shift $(($OPTIND-1))

if [ $# -lt 2 ]; then
	usage
	exit 1
fi

image=$1
mount_work_directory="$2"
shift 2

printf "Running docker[%s] for command \"%s\". Workdir(host): \"%s\"\n" "$image" "$*" "$mount_work_directory"
docker run $docker_options --rm --volume "$mount_work_directory:/workdir" --workdir=/workdir "$image" "$@"

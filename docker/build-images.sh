#!/usr/bin/env sh

set -eu

image_tag=$(date +%y%m%d)
docker_options=""
cache_image=""
cache_from=""

usage()
{
	echo "Usage: build-images.sh [-d <docker options>] [-t <tag>] [-c] [-u <user>] [-p <token>]\n\t<building path> <repository> [repository ...]"
} >&2

pull_cache_image()
{
	if [ -z "$cache_image" ]; then
		return 0
	fi

	echo "Try to pull image for cache <== \"$cache_image\""
	if docker pull --quiet "$cache_image" >/dev/null 2>&1; then
		echo "Cache image is viable"
		cache_from="--cache-from '$cache_image'"
	else
		echo "WARNING: Cache image is not available."
	fi
}

while getopts "t:d:c:" options; do
	case "${options}" in
		t)
		image_tag=${OPTARG}
		;;
		d)
		docker_options="${OPTARG}"
		;;
		c)
		cache_image="${OPTARG}"
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

docker_dir=$1
shift

pull_cache_image

tagging=""
for repos in "$@"; do
	tagging="$tagging -t '$repos:latest' -t '$repos:$image_tag'"
done

printf "Building image by directory \"%s\":\n\t%s\n" "$docker_dir" "$tagging"
if eval docker build --quiet $docker_options $cache_from $tagging "$docker_dir"; then
	echo "Building image is a success."
else
	echo "Building image has failed."
	exit 1
fi

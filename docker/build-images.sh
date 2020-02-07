#!/usr/bin/env sh

set -eu

image_tag=$(date +%y%m%d)
cache_repos_username=${CACHE_REPOS_USERNAME:-}
cache_repos_token=${CACHE_REPOS_TOKEN:-}
docker_options=""
use_cache=0
cache_from=""

usage()
{
	echo "Usage: build-images.sh [-d <docker options>] [-t <tag>] [-c] [-u <user>] [-p <token>]\n\t<building path> <repository> [repository ...]"
} >&2

pull_cache_image()
{
	if [ $use_cache -eq 0 ]; then
		return 0
	fi

	first_image="$1"
	cache_host_name=$(echo $first_image | sed -re 's#^([^/]+).*$#\1#')

	if [ -n "$cache_repos_username" ]; then
		echo Log-in to \"$cache_host_name\" for pull cache
		docker login -u "$cache_repos_username" --password "$cache_repos_token" "$cache_host_name"
	fi

	cache_image="$first_image:latest"

	echo "Try to pull image for cache >> \"$cache_image\""
	if docker pull --quiet "$cache_image" >/dev/null 2>&1; then
		echo "Cache image is viable"
		cache_from="--cache-from '$cache_image'"
	else
		echo "WARNING: Cache image is not available."
	fi

	if [ -n "$cache_repos_username" ]; then
		echo Log-out from \"$cache_host_name\"
		docker logout "$cache_host_name"
	fi
}

while getopts "t:u:p:d:c" options; do
	case "${options}" in
		t)
		image_tag=${OPTARG}
		;;
		u)
		cache_repos_username=${OPTARG}
		;;
		p)
		cache_repos_token=${OPTARG}
		;;
		d)
		docker_options="${OPTARG}"
		;;
		c)
		use_cache=1
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

pull_cache_image "$@"

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

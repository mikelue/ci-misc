#!/usr/bin/env sh

set -eu

image_tag=$(date +%y%m%d)
cache_repos_username=${CACHE_REPOS_USERNAME:-}
cache_repos_token=${CACHE_REPOS_TOKEN:-}
docker_options=""
use_cache=0
cache_from=""

pull_cache_image()
{
	if [ $use_cache -eq 0 ]; then
		return 0
	fi

	first_image="$1"
	cache_host_name=$(echo $first_image | sed -re 's#^([^/]+).*$#\1#')

	if [ -n "$cache_repos_username" ]; then
		echo Log-in to \"$cache_host_name\" for pull cache
		echo $cache_repos_token | docker login -u "$cache_repos_username" --password-stdin "$cache_host_name"
	fi

	cache_image="$first_image:latest"

	echo "Try to pull image for cache >> \"$cache_image\""
	if docker pull --quiet "$cache_image" >/dev/null 2>&1; then
		echo "Cache image is viable"
		cache_from="--cache-from '$cache_image'"
	else
		echo "WARNING: Cache image is not available."
	fi

	echo Log-out from \"$cache_host_name\"
	docker logout "$cache_host_name"
}

while getopts ":t:u:p:d:c" options; do
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
		>&2 echo "Unknown options: \"-$OPTARG\""
		>&2 echo "Usage: build-images.sh <building path> <repository> [repository ...]"
		exit 1
		;;
	esac
done

shift $(($OPTIND - 1))

if [ $# -eq 0 ]; then
	echo "Needs: build-images.sh <building path> <repository>"
	exit 1
elif [ $# -eq 1 ]; then
	echo "Needs: build-images.sh $1 <repository>"
	exit 1
fi

docker_dir=$1
shift

pull_cache_image "$@"

tagging=""
for repos in "$@"; do
	tagging="$tagging -t '$repos:latest' -t '$repos:$image_tag'"
done

if eval docker build --quiet $docker_options $cache_from $tagging "$docker_dir"; then
	echo Building image from \"$docker_dir\" is a success.
fi

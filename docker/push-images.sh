#!/usr/bin/env sh
set -eu

repos_host_name=""
cleanup()
{
	if [ -n "$repos_host_name" ]; then
		echo Log-out from \"$repos_host_name\"
		docker logout "$repos_host_name"
	fi
}

trap cleanup EXIT

repos_username=${PUSH_REPOS_USERNAME:-}
repos_token=${PUSH_REPOS_PASSWORD:-}
docker_options=

while getopts ":u:p:d:" options; do
	case "${options}" in
		u)
		repos_username=${OPTARG}
		;;
		p)
		repos_token=${OPTARG}
		;;
		d)
		docker_options="${OPTARG}"
		;;
		\?)
		>&2 echo "Unknown options: \"-$OPTARG\""
		>&2 echo "Usage: push-images.sh <image name> <tag> [tag ...]"
		exit 1
		;;
	esac
done

shift $(($OPTIND - 1))

if [ $# -eq 0 ]; then
	echo "Needs: push-images.sh <image name> <tag>"
	exit 1
elif [ $# -eq 1 ]; then
	echo "Needs: push-images.sh $1 <tag>"
	exit 1
fi

image_name="$1"
shift

if [ -n "$repos_username" ]; then
	repos_host_name=$(echo "$image_name" | sed -re 's#^([^/]+).*$#\1#')

	echo Log-in to \"$repos_host_name\"
	echo $repos_token | docker login -u "$repos_username" --password-stdin "$repos_host_name"
fi

for tag in "$@"; do
	echo "Pushing image: \"$image_name:$tag\""
	if eval docker push $docker_options \"$image_name:$tag\"; then
		echo "Pushing image is a success."
	else
		echo "Pushing image has failed."
	fi
done

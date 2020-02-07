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

usage()
{
	echo "Usage: "
	echo "push-images.sh [-d <docker options>] [-u <user>] [-p <token>] <image> <tag> [tags ...]"
} >&2

trap cleanup EXIT

repos_username=${PUSH_REPOS_USERNAME:-}
repos_token=${PUSH_REPOS_PASSWORD:-}
docker_options=

while getopts "u:p:d:" options; do
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
		usage
		exit 1
		;;
	esac
done

shift $(($OPTIND - 1))

if [ $# -lt 2 ]; then
	usage
	exit 1
fi

image_name="$1"
shift

if [ -n "$repos_username" ]; then
	repos_host_name=$(echo "$image_name" | sed -re 's#^([^/]+).*$#\1#')

	echo Log-in to \"$repos_host_name\"
	echo "$repos_token" | docker login -u "$repos_username" --password-stdin "$repos_host_name"
fi

exit_status=0
for tag in "$@"; do
	echo "Pushing image: \"$image_name:$tag\""
	if eval docker push $docker_options \"$image_name:$tag\"; then
		echo "Pushing image is a success."
	else
		echo "Pushing image has failed."
		exit_status=1
	fi
done

exit $exit_status

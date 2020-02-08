#!/usr/bin/env sh

set -eu

usage()
{
	echo "Usage: aws-ecr-get-login.sh [-o '<aws options>'] [aws profile]"
} >&2
check_env()
{
	local var_name="$1"
	local var_value=$(eval echo \${$var_name:-\<EMPTY\>})

	if [ "$var_value" = '<EMPTY>' ]; then
		echo "Needs \"\$$var_name\""
		usage
		return 1
	fi
} >&2

aws_options=""
aws_profile="ci-user"

readonly sed_script="s/-e none //"
get_login_by_aws()
{
	aws --profile $aws_profile configure set aws_access_key_id $AWS_ACCESS_KEY_ID
	aws --profile $aws_profile configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
	aws --profile $aws_profile configure set region $AWS_REGION

	if ! aws_login=$(2>&1 aws --profile $aws_profile $aws_options ecr get-login); then
		>&2 echo "aws erc get-login has error: >>>>>\n$aws_login\n<<<<<"
		return 1
	fi

	echo $aws_login | sed -e "$sed_script"
}
get_login_by_docker()
{
	local image="mikesir87/aws-cli"

	if ! pull_result=$(docker pull --quiet $image 2>&1); then
		>&2 echo "Unable to pull docker image: \"$image\" ==>\n$pull_result"
		return 1
	fi

	if ! aws_login=$(2>&1 docker run --rm \
		-e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
		-e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
		$image aws --region "$AWS_REGION" ecr get-login)
	then
		>&2 echo "aws erc get-login has error(in docker): >>>>>\n$aws_login\n<<<<<"
		return 1
	fi

	echo $aws_login | sed -e "$sed_script"
}
detect_exec()
{
	case "$1" in
		aws)
			echo "aws"
			return 0
			;;
		docker)
			echo "docker"
			return 0
			;;
	esac

	if command -v aws >/dev/null 2>&1; then
		echo "aws"
		return 0
	fi

	if command -v docker >/dev/null 2>&1; then
		echo "docker"
		return 0
	fi

	>&2 echo 'Unable to find "aws" or "docker" command'
	return 1
}

aws_exec="auto"
while getopts "e:a:" opt
do
  case $opt in
	a)
	aws_options="$OPTARG"
	;;
	e)
	aws_exec="$OPTARG"
	;;
	\?)
	usage
	exit 1
  esac
done
shift $(($OPTIND-1))

aws_profile=${1:-ci-user}
check_result=0
if ! check_env 'AWS_ACCESS_KEY_ID'; then
	check_result=1
fi
if ! check_env 'AWS_SECRET_ACCESS_KEY'; then
	check_result=1
fi
if ! check_env 'AWS_REGION'; then
	check_result=1
fi

if [ $check_result -ne 0 ]; then
	exit $check_result
fi

case "$(detect_exec $aws_exec)" in
	aws)
	get_login_by_aws
	;;
	docker)
	get_login_by_docker
	;;
esac

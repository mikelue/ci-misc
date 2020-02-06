#!/usr/bin/env sh

set -eu

usage()
{
	echo "Usage: aws-ecr-get-login.sh -o '<aws options>' [aws profile]"
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
while getopts "o:" opt
do
  case $opt in
	o)
	aws_options="$OPTARG"
	;;
	\?)
	usage
	exit 1
  esac
done
shift $(($OPTIND-1))

aws_profile=${1:-ci-user}

check_result=0
if ! check_env 'AWS_ACCESS_ID'; then
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

aws --profile $aws_profile configure set aws_access_key_id $AWS_ACCESS_ID
aws --profile $aws_profile configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws --profile $aws_profile configure set region $AWS_REGION

if ! aws_login=$(2>&1 aws --profile $aws_profile $aws_options ecr get-login); then
	>&2 echo "aws erc get-login has error: >>>>>\n$aws_login\n<<<<<"
	exit 1
fi

echo $aws_login | sed -e 's/-e none //'

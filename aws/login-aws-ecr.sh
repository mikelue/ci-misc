#!/usr/bin/env bash

set -e

check_env()
{
    var_name="$1"
    var_value=$(eval echo $var_name)

    if [[ -z "$var_value" ]]; then
        >&2 echo "Needs \"$var_name\""
        exit 1
    fi
}

target_ecr=$1
aws_profile=${2:-ci-user}

check_result=0
if ! ( check_env "\$AWS_ACCESS_ID" ); then
    check_result=1
fi
if ! ( check_env "\$AWS_SECRET_ACCESS_KEY" ); then
    check_result=1
fi
if ! ( check_env "\$AWS_REGION" ); then
    check_result=1
fi

if [[ $check_result -ne 0 ]]; then
    exit $check_result
fi

echo "Set-up access profile[$aws_profile]"
aws --profile $aws_profile configure set aws_access_key_id $AWS_ACCESS_ID
aws --profile $aws_profile configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws --profile $aws_profile configure set region $AWS_REGION

echo "Perform login to AWS ECR: \"$target_ecr\""

aws --profile $aws_profile ecr get-login | sed -rn -e 's/.*-p ([^[:blank:]]+).*/\1/p' | docker login -u AWS --password-stdin https://$target_ecr

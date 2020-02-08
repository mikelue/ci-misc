#!/usr/bin/env bats

load "$BATS_TEST_DIRNAME/../../bats/lib.bash"

testedScript="$BATS_TEST_DIRNAME/../aws-ecr-get-login.sh"

@test "aws arguments(-d)" {
	shellmock_expect aws --status 0 --type partial --match '-k v1'
	shellmock_expect aws --status 0 --type partial --match '--profile ci-user'

	run $testedScript -a "-k v1"
	eval $EVAL_OUTPUT_RESULT_IF_FAILED
}

@test "aws profile" {
	shellmock_expect aws --status 0 --type partial --match '--profile ci-custom-profile'
	shellmock_expect aws --status 0 --type partial --match 'ecr get-login'

	run $testedScript ci-custom-profile
	eval $EVAL_OUTPUT_RESULT_IF_FAILED
}

@test "get rid of \"-e none\"" {
	shellmock_expect aws --status 0 --type partial --match '--profile ci-user'
	shellmock_expect aws --status 0 --output "some login -e none -p aaa" --type partial --match 'ecr get-login'

	run $testedScript -e aws
	eval $EVAL_OUTPUT_RESULT_IF_FAILED
	grep -vqF "-e none" <<<"$output"
}

setup() {
	. shellmock

	export AWS_ACCESS_KEY_ID=akid AWS_SECRET_ACCESS_KEY=ak AWS_REGION=rg
}

teardown() {
	if [ -z "$TEST_FUNCTION" ]; then
		shellmock_clean
	fi

	export -n AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION
}

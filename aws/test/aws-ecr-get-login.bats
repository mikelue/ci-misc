#!/usr/bin/env bats

load "$BATS_TEST_DIRNAME/../../bats/lib.bash"

testedScript="$BATS_TEST_DIRNAME/../aws-ecr-get-login.sh"

@test "Illegal option" {
	run $testedScript -z
	assert_status $status 1
	assert_illegal_option "$output" -z
}

@test "No arg for options" {
	run $testedScript -a
	assert_usage $status "$output" -a

	run $testedScript -e
	assert_usage $status "$output" -e
}

assert_needs_env()
{
	local output="$1"
	local status=$2
	local var_name="$3"

	assert_status $status 1
	assert_text "$output" "Needs \"\$$var_name\""
}

# Tests the error messages if any of needed environment variables is missing
@test "No needed environment variables" {
	export -n AWS_ACCESS_KEY_ID
	run $testedScript
	assert_needs_env "$output" $status "AWS_ACCESS_KEY_ID"
	export AWS_ACCESS_KEY_ID=akid

	export -n AWS_SECRET_ACCESS_KEY
	run $testedScript
	assert_needs_env "$output" $status "AWS_SECRET_ACCESS_KEY"
	export AWS_SECRET_ACCESS_KEY=ak

	export -n AWS_REGION
	run $testedScript
	assert_needs_env "$output" $status "AWS_REGION"
	export AWS_REGION=rg
}

skip_if_no_env_vars()
{
	if [ -z ${AWS_ACCESS_KEY_ID:-} ]; then
		skip "No value of \$AWS_ACCESS_KEY_ID"
	fi
	if [ -z ${AWS_SECRET_ACCESS_KEY:-} ]; then
		skip "No value of \$AWS_SECRET_ACCESS_KEY"
	fi
	if [ -z ${AWS_REGION:-} ]; then
		skip "No value of \$AWS_REGION"
	fi
}

@test "ecr get-login by invoking aws command" {
	skip_if_no_env_vars
	if [ -x aws ]; then
		skip "No \"aws\" command"
	fi

	run $testedScript -e aws
	eval $EVAL_OUTPUT_RESULT_IF_FAILED
	assert_text "$output" "docker login"
}

@test "ecr get-login by invoking docker run(aws image)" {
	skip_if_no_env_vars
	if [ -x docker ]; then
		skip "No \"docker\" command"
	fi

	run $testedScript -e docker
	eval $EVAL_OUTPUT_RESULT_IF_FAILED
	assert_text "$output" "docker login"
}

setup()
{
	if [ "$BATS_TEST_NAME" == "test_No_needed_environment_variables" ]; then
		export AWS_ACCESS_KEY_ID=akid AWS_SECRET_ACCESS_KEY=ak AWS_REGION=rg
	fi
}
teardown()
{
	if [ "$BATS_TEST_NAME" == "test_No_needed_environment_variables" ]; then
		export -n AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION
	fi
}

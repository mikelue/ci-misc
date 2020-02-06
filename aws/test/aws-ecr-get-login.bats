#!/usr/bin/env bats

testedScript="$BATS_TEST_DIRNAME/../aws-ecr-get-login.sh"

@test "Missed environment variables" {
	AWS_ACCESS_ID=""

	run $testedScript

	[ $status -eq 1 ]
	grep -q "Usage" <<<"$output"
}

@test "Test Connection" {
	if [ -z ${AWS_ACCESS_ID:-} ]; then
		skip "No value of \$AWS_ACCESS_ID"
	fi
	if [ -z ${AWS_SECRET_ACCESS_KEY:-} ]; then
		skip "No value of \$AWS_SECRET_ACCESS_KEY"
	fi
	if [ -z ${AWS_REGION:-} ]; then
		skip "No value of \$AWS_REGION"
	fi

	run $testedScript

	[ $status -eq 0 ]
	grep -q "docker login" <<<"$output"
}

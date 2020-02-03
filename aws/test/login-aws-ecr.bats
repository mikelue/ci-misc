#!/usr/bin/env bats

testedScript="$BATS_TEST_DIRNAME/../login-aws-ecr.sh"

@test "Missed environment variables" {
    run $testedScript

    [ $status -eq 1 ]
	grep -q "Usage" <<<"$output"
}

@test "Connect timeout" {
	if ! command -v aws; then
		skip "No AWS command"
	fi

	run env AWS_ACCESS_ID=aid AWS_SECRET_ACCESS_KEY=akey AWS_REGION=aregison \
		$testedScript no-such-host.dkr.ecr.ap-northeast-1.amazonaws.com

	>&3 echo $output
    [ $status -eq 1 ]
	grep -q "Could not connect" <<<"$output"
}

#!/usr/bin/env bats

testedScript="$BATS_TEST_DIRNAME/../login-aws-ecr.sh"

@test "Missed environment variables" {
    run $testedScript

    [ $status -eq 1 ]
}

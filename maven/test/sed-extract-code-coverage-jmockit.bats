#!/usr/bin/env bats
load "$BATS_TEST_DIRNAME/../../bats/lib.bash"

testScript="$BATS_TEST_DIRNAME/../extract-code-coverage-jmockit.sh"

@test "Usage" {
    run $testScript

	assert_status "$status" 1
    assert_text "$output" "Usage"
}

@test "No existing of index.html" {
    run $testScript mvnprj-noexists

	assert_status "$status" 1
    assert_text "$output" "Coverage file is not existing"
}

@test "Extract code coverage" {
    run $testScript "$BATS_TEST_DIRNAME/mvnprj-code-coverage"

	eval $EVAL_OUTPUT_RESULT_IF_FAILED
    assert_text "$output" "Code coverage: 90.23%"
}

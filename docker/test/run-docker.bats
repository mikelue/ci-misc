#!/usr/bin/env bats

testedScript="$BATS_TEST_DIRNAME/../run-docker.sh"
load "$BATS_TEST_DIRNAME/../../bats/lib.bash"

@test "Illegal option" {
	run $testedScript -z
	assert_status $status 1
	assert_illegal_option "$output" -z
}

@test "No arg for options" {
	run $testedScript -d
	assert_usage $status "$output" -d

	run $testedScript -w
	assert_usage $status "$output" -w
}

@test "Not enough arguments" {
	run $testedScript
	assert_usage $status "$output"
}

@test "Run docker(without workdir of host)" {
	if ! command -v docker; then
		skip "No docker cli"
	fi

	run $testedScript -v alpine:latest echo hello run-docker

	eval $EVAL_OUTPUT_RESULT

	# ========================================
	# Asserts the output text
	# ========================================
	eval $EVAL_OUTPUT_RESULT_IF_FAILED
	assert_text "$output" "hello run-docker"
	# :~)
}

@test "Run docker(with workdir of host)" {
	if ! command -v docker; then
		skip "No docker cli"
	fi

	# ========================================
	# Pipe text to file "test.output"
	# ========================================
	workdir="$BATS_TMPDIR/run-docker.workdir"
	run $testedScript -w "$workdir" alpine:latest sh -c "'echo hello run-docker >test.output'"
	# :~)

	# ========================================
	# Asserts the content of output file
	# ========================================
	eval $EVAL_OUTPUT_RESULT_IF_FAILED
	assert_text $(cat '$workdir/test.output') "hello run-docker"
	# :~)
}

#!/usr/bin/env bats

load "$BATS_TEST_DIRNAME/../../bats/lib.bash"

testedScript="$BATS_TEST_DIRNAME/../run-docker.sh"
fake_image="no-image:no-tag"

@test "Execution of docker run is a failure" {
	shellmock_expect docker --status 0 --type partial --match 'pull'
	shellmock_expect docker \
		--status 125 --output "Unable to find image \"$fake_image\" locally." \
		--type partial --match 'run'

	run $testedScript $fake_image

	[ $status -eq 125 ]
	assert_text "$output" "Unable to find image"
}

@test "Applies arguments to docker run(-d)" {
	shellmock_expect docker --status 0 --type partial --match 'pull'
	shellmock_expect docker \
		--status 0 \
		--type partial --match '-c v1'

	run $testedScript -d "-c v1" $fake_image
	eval $EVAL_OUTPUT_RESULT_IF_FAILED
}

@test "Applies -v 'fake-dir:/workdir' for docker run(-w)" {
	shellmock_expect docker --status 0 --type partial --match 'pull'
	shellmock_expect docker \
		--status 0 \
		--type partial --match '-v fake-dir:/workdir'

	run $testedScript -w "fake-dir" $fake_image
	eval $EVAL_OUTPUT_RESULT_IF_FAILED
}

@test "Applies verbose output(-v)" {
	shellmock_expect docker --status 0 --type partial --match 'pull'
	shellmock_expect docker \
		--status 0 \
		--type partial --match 'run'

	run $testedScript -w fake-dir -v $fake_image sh

	eval $EVAL_OUTPUT_RESULT_IF_FAILED
	assert_text "$output" "Running docker"
	assert_text "$output" "start command"
	assert_text "$output" "Work directory"
}

@test "Applies \"--rm --workdir=/workdir\" for docker run" {
	shellmock_expect docker --status 0 --type partial --match 'pull'
	shellmock_expect docker \
		--status 0 \
		--type partial --match '--rm --workdir=/workdir'

	run $testedScript -w "fake-dir" $fake_image
	eval $EVAL_OUTPUT_RESULT_IF_FAILED
}

setup() {
	. shellmock
}

teardown() {
	if [ -z "$TEST_FUNCTION" ]; then
		shellmock_clean
	fi
}

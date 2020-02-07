#!/usr/bin/env bats

testedScript="$BATS_TEST_DIRNAME/../push-images.sh"
buildScript="$BATS_TEST_DIRNAME/../build-images.sh"
github_docker_registry="docker.pkg.github.com/mikelue/ci-misc"

load "$BATS_TEST_DIRNAME/../../bats/lib.bash"

@test "Illegal option" {
	run $testedScript -z
	assert_status $status 1
	assert_illegal_option "$output" -z
}

@test "No arg for options" {
	run $testedScript -d
	assert_usage $status "$output" -d

	run $testedScript -u
	assert_usage $status "$output" -u

	run $testedScript -p
	assert_usage $status "$output" -p
}

@test "Not enough arguments" {
	run $testedScript
	assert_usage $status "$output"

	run $testedScript fake-image
	assert_usage $status "$output"
}

build_images()
{
	local tag=$1
	shift
	$buildScript -t $tag sample-docker-1 "$@"
}

@test "Push images" {
	if [[ -z "$GITHUB_ACTION" ]]; then
		skip "Not in environment of github.com actions"
	fi

	local image_name="$github_docker_registry/push-test-image"

	run build_images test-case "$image_name"
	eval $EVAL_OUTPUT_RESULT_IF_FAILED
	run build_images test-case-2 "$image_name"
	eval $EVAL_OUTPUT_RESULT_IF_FAILED

	run $testedScript \
		-u mikelue -p "$GITHUB_TOKEN" \
		"$image_name" \
		latest test-case

	eval $EVAL_OUTPUT_RESULT_IF_FAILED
	assert_text "$output" "Pushing image is a success"
}

#!/usr/bin/env bats

load "$BATS_TEST_DIRNAME/../../bats/lib.bash"

run_image_and_assert()
{
	image=$1

	echo "Tests image by running: \"$image\""
	run docker run $image

	eval $EVAL_OUTPUT_RESULT_IF_FAILED
	assert_text "$output" "sample-docker-1"
} 1>&3 2>&3

testedScript="$BATS_TEST_DIRNAME/../build-images.sh"
github_docker_registry="docker.pkg.github.com/mikelue/ci-misc"

@test "Illegal option" {
	run $testedScript -z
	assert_status $status 1
	assert_illegal_option "$output" -z
}

@test "No arg for options" {
	run $testedScript -t
	assert_usage $status "$output" -t

	run $testedScript -u
	assert_usage $status "$output" -u

	run $testedScript -p
	assert_usage $status "$output" -p

	run $testedScript -d
	assert_usage $status "$output" -d
}

@test "Not enough arguments" {
	run $testedScript
	assert_usage $status "$output"

	run $testedScript sample_folder
	assert_status $status 1
	assert_usage $status "$output"
}

@test "Build sample docker image(no cache)" {
	if [[ -z "$GITHUB_ACTION" ]]; then
		skip "Not in environment of github.com actions"
	fi

	run $testedScript -t test-case sample-docker-1 docker.sample.test/case1 docker.sample2.test/case1

	eval $EVAL_OUTPUT_RESULT_IF_FAILED

	# Asserts the built image
	run_image_and_assert docker.sample.test/case1:latest
	run_image_and_assert docker.sample.test/case1:test-case
	run_image_and_assert docker.sample2.test/case1:latest
	run_image_and_assert docker.sample2.test/case1:test-case
}

@test "Build sample docker image(try pull, no cache)" {
	if [[ -z "$GITHUB_ACTION" ]]; then
		skip "Not in enviornment of github.com actions"
	fi

	run $testedScript \
		-c -u mikelue -p "$GITHUB_TOKEN" \
		-t test-case sample-docker-1 docker.pkg.github.com/mikelue/ci-misc/ci-nocache-image

	eval $EVAL_OUTPUT_RESULT_IF_FAILED

	# Asserts the missed cache of image
	assert_text "$output" "WARNING: Cache image is not available."

	run_image_and_assert docker.pkg.github.com/mikelue/ci-misc/ci-nocache-image:latest
	run_image_and_assert docker.pkg.github.com/mikelue/ci-misc/ci-nocache-image:test-case
}

build_and_push_cache()
{
	run $testedScript \
		-t test-case sample-docker-1 $github_docker_registry/ci-cache-image

	>&3 echo "Building \"ci-cache-image\""
	docker login -u "mikelue" -p "$GITHUB_TOKEN" docker.pkg.github.com

	>&3 echo "Pushing \"ci-cache-image\""
	docker push $github_docker_registry/ci-cache-image:latest
	docker push $github_docker_registry/ci-cache-image:test-case
	docker logout docker.pkg.github.com

	>&3 echo "Cleaning \"ci-cache-image\" of local"
	docker image rm $github_docker_registry/ci-cache-image:latest
	docker image rm $github_docker_registry/ci-cache-image:test-case
	docker image prune -f
}

@test "Build sample docker image(pull with cache)" {
	if [[ -z "$GITHUB_ACTION" ]]; then
		skip "Not in environment of github.com actions"
	fi

	run build_and_push_cache
	eval $EVAL_OUTPUT_RESULT_IF_FAILED

	run $testedScript \
		-c -u mikelue -p "$GITHUB_TOKEN" \
		-t test-case sample-docker-1 $github_docker_registry/ci-cache-image

	eval $EVAL_OUTPUT_RESULT_IF_FAILED

	# Asserts the cache hit of image
	assert_text "$output" "Cache image is viable"

	run_image_and_assert $github_docker_registry/ci-cache-image:latest
	run_image_and_assert $github_docker_registry/ci-cache-image:test-case
}

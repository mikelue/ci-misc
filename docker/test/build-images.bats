#!/usr/bin/env bats

run_image_and_assert()
{
	image=$1

	echo "Tests image by running: \"$image\""
	run docker run $image

	[ $status -eq 0 ]
	grep -q "sample-docker-1" <<<"$output"
} 1>&3 2>&3
output_result()
{
	echo -e "\n[OUTPUT] build-images.sh >>>>>\n$1\n<<<<<\n"
} 1>&3 2>&3

testedScript="$BATS_TEST_DIRNAME/../build-images.sh"
github_docker_registry="docker.pkg.github.com/mikelue/ci-misc"

@test "Unknown options" {
	run $testedScript -z

	[ $status -eq 1 ]
	grep -q -e "Unknown options:" <<<"$output"
	grep -q -e "-z" <<<"$output"
}

@test "Needs building path" {
	run $testedScript

	[ $status -eq 1 ]
	grep -q -Fe "<building path>" <<<"$output"
}

@test "Needs repository" {
	run $testedScript sample_folder

	[ $status -eq 1 ]
	grep -q -Fe "<repository>" <<<"$output"
}

@test "Build sample docker image(no cache)" {
	if [[ -z "$GITHUB_ACTION" ]]; then
		skip "Not in environment of github.com actions"
	fi

	run $testedScript -t test-case sample-docker-1 docker.sample.test/case1 docker.sample2.test/case1

	output_result "$output"
	[ $status -eq 0 ]

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

	output_result "$output"
	[ $status -eq 0 ]

	# Asserts the missed cache of image
	grep -q "WARNING: Cache image is not available." <<<"$output"

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
	[ $status -eq 0 ]

	run $testedScript \
		-c -u mikelue -p "$GITHUB_TOKEN" \
		-t test-case sample-docker-1 $github_docker_registry/ci-cache-image

	output_result "$output"
	[ $status -eq 0 ]

	# Asserts the cache hit of image
	grep -q "Cache image is viable" <<<"$output"

	run_image_and_assert $github_docker_registry/ci-cache-image:latest
	run_image_and_assert $github_docker_registry/ci-cache-image:test-case
}

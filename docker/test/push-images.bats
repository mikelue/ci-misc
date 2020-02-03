#!/usr/bin/env bats

output_result()
{
	>&3 echo -e "\n[OUTPUT] push-images.sh >>>>>\n$1\n<<<<<\n"
}

testedScript="$BATS_TEST_DIRNAME/../push-images.sh"
buildScript="$BATS_TEST_DIRNAME/../build-images.sh"
github_docker_registry="docker.pkg.github.com/mikelue/ci-misc"

@test "Unknown options" {
	run $testedScript -z

	[ $status -eq 1 ]
	grep -e "Unknown options:" <<<"$output"
	grep -e "-z" <<<"$output"
}

@test "Needs image name" {
	run $testedScript

	[ $status -eq 1 ]
	grep -Fe "<image name>" <<<"$output"
}

@test "Needs tag" {
	run $testedScript fake-image

	[ $status -eq 1 ]
	grep -Fe "<tag>" <<<"$output"
}

build_images()
{
	tag=$1
	shift
	$buildScript -t $tag sample-docker-1 "$@"
}

@test "Push images" {
	if [[ -z "$GITHUB_ACTION" ]]; then
		skip "Not in environment of github.com actions"
	fi

	run build_images test-case $github_docker_registry/push-test-image
	[ $status -eq 0 ]
	run build_images test-case-2 $github_docker_registry/push-test-image
	[ $status -eq 0 ]

	run $testedScript \
		-u mikelue -p $GITHUB_TOKEN \
		$github_docker_registry/push-test-image \
		latest test-case
	output_result "$output"

	[ $status -eq 0 ]
	grep 'Push image ".\+:latest" is a success' <<<"$output"
	grep 'Push image ".\+:test-case" is a success' <<<"$output"
}

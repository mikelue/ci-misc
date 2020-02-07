#!/usr/bin/env bats

load "$BATS_TEST_DIRNAME/../../bats/lib.bash"

testedScript="$BATS_TEST_DIRNAME/../build-images.sh"
fake_image="fake.repos/fake-image"

@test "\"docker build\" has error" {
	shellmock_expect docker \
		--status 1 --output "Unable to build image" \
		--type partial --match 'build'

	run $testedScript sample_folder $fake_image

	assert_status $status 1
	assert_text "$output" "Unable to build image"
}

@test "Applies tag(-t)" {
	local samle_tag=case-1
	shellmock_expect docker \
		--status 0 \
		--type partial --match "-t $fake_image:latest -t $fake_image:case-1"

	run $testedScript -t case-1 sample_folder $fake_image
	eval $EVAL_OUTPUT_RESULT_IF_FAILED
}

@test "Applies docker options(-d)" {
	shellmock_expect docker \
		--status 0 \
		--type partial --match '-v c1'

	run $testedScript -d "-v c1" sample_folder $fake_image
	eval $EVAL_OUTPUT_RESULT_IF_FAILED
}

@test "Applies docker cache(-c)" {
	shellmock_expect docker \
		--status 0 \
		--type partial --match 'pull'
	shellmock_expect docker \
		--status 0 \
		--type partial --match '--cache-from'

	run $testedScript -c sample_folder $fake_image
	eval $EVAL_OUTPUT_RESULT_IF_FAILED
}

@test "Applies docker cache(-c) with login to docker registry(-u, -p)" {
	shellmock_expect docker \
		--status 0 \
		--type partial --match 'login -u user1 --password pass1'
	shellmock_expect docker \
		--status 0 \
		--type partial --match 'logout'
	shellmock_expect docker \
		--status 0 \
		--type partial --match 'pull'
	shellmock_expect docker \
		--status 0 \
		--type partial --match '--cache-from'

	run $testedScript -c -u user1 -p pass1 sample_folder $fake_image
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

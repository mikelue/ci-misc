#!/usr/bin/env bats

load "$BATS_TEST_DIRNAME/../../bats/lib.bash"

testedScript="$BATS_TEST_DIRNAME/../push-images.sh"
fake_image="no-image"

@test "Login info of docker(-u, -p)" {
	shellmock_expect docker \
		--status 0 \
		--type partial --match 'login -u user1 --password-stdin'

	shellmock_expect docker --status 0 --type partial --match 'push'
	shellmock_expect docker --status 0 --type partial --match 'logout'

	run $testedScript -u user1 -p pass1 $fake_image case-1
	eval $EVAL_OUTPUT_RESULT_IF_FAILED
}

@test "Docker options(-d)" {
	shellmock_expect docker \
		--status 0 \
		--type partial --match '-v c1'

	run $testedScript -d "-v c1" $fake_image case-1
	eval $EVAL_OUTPUT_RESULT_IF_FAILED
}

@test "\"docker push\" has error" {
	shellmock_expect docker \
		--status 1 --output "Unable to push image" \
		--type partial --match 'push'

	run $testedScript no-such-name/push-test-image case-1
	assert_status $status 1
	assert_text "$output" "Unable to push image"
}

setup() {
	. shellmock
}

teardown() {
	if [ -z "$TEST_FUNCTION" ]; then
		shellmock_clean
	fi
}

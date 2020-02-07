#!/usr/bin/env bash

output_result()
{
	local test_title="$1"
	local status=$2
	local output="$3"

	printf "\n[OUTPUT][%d] \"%s\" >>>>>\n%s\n<<<<<\n" "$status" "$test_title" "$output"
} >&3

output_result_if_failed()
{
	local status=$2

	if [ $status -ne 0 ]; then
		echo "Status(bats run) is not 0($status)."
		output_result "$1" $status "$3"
		return 1
	fi
} >&3

assert_illegal_option()
{
	local search_pattern="Illegal option $2"
	assert_text "$1" "$search_pattern"
} >&3

assert_status()
{
	local status=$1
	local expected=$2

	if [ $status -ne $2 ]; then
		printf "Expected status[%d], but got [%d]\n" $expected $status
		return 1
	fi
} >&3

assert_no_arg()
{
	local search_pattern="No arg for $arg option"
	assert_text "$1" "$search_pattern"
} >&3

assert_text()
{
	local output="$1"
	local search_pattern="$2"

	if ! grep -Fqe "$search_pattern" <<<"$output"; then
		echo "Could not find text: \"$search_pattern\""
		return 1
	fi
}

assert_regexp()
{
	local output="$1"
	local search_pattern="$2"

	if ! grep -Eqe "$search_pattern" <<<"$output"; then
		echo "Could not find regexp: \"$search_pattern\""
		return 1
	fi
}

assert_pcre()
{
	local output="$1"
	local search_pattern="$2"

	if ! grep -Pqe "$search_pattern" <<<"$output"; then
		echo "Could not find PCRE: \"$search_pattern\""
		return 1
	fi
}

assert_usage()
{
	local status=$1
	local output="$2"
	local arg="${3:-}"

	if [ -n "$arg" ]; then
		assert_no_arg "$output" $arg
	fi

	if ! [ $status -eq 1 ]; then
		echo "Status: expected [1] but found [$status]"
		return 1
	fi

	assert_text "$output" "Usage"
} >&3

readonly EVAL_OUTPUT_RESULT='output_result "$(basename '$BATS_TEST_FILENAME')[$BATS_TEST_NUMBER]" $status "$output"'
readonly EVAL_OUTPUT_RESULT_IF_FAILED='output_result_if_failed "$(basename '$BATS_TEST_FILENAME')[$BATS_TEST_NUMBER]" $status "$output"'
readonly EVAL_ASSERT_STATUS='assert_status $status'

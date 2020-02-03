#!/usr/bin/env bats

testedScript="$BATS_TEST_DIRNAME/../clean-local-repository.sh"

seconds_per_day=86400

touch_file()
{
	file_path=$1
	unix_time=${2:-$(date -u +%s)}

	mkdir -p $(dirname $file_path)
	touch -d "@$unix_time" $file_path
}

@test "Empty argument" {
	run $testedScript

	[ $status -eq 1 ]
	grep -s "Usage" <<<"$output"
}

@test "No local repository" {
	run $testedScript no-such-folder

	grep -s "No repository folder" <<<"$output"
}

@test "Clean out dated artifacts(90 days)" {
	sample_repos=$BATS_TMPDIR/.sample_m2

	rm -rf $BATS_TMPDIR/.sample_m2/repository

	old_date=$(date -u +%s)
	let "old_date -= $seconds_per_day * 91"

	old_file_1="$sample_repos/repository/guru/mikelue/sample/1.1/sample-1.1.pom"
	old_file_2="$sample_repos/repository/guru/mikelue/sample/1.2/sample-1.2.pom"
	old_file_3="$sample_repos/repository/org/verve/goodie/1.0/goodie-1.0.pom"
	new_file_1="$sample_repos/repository/guru/mikelue/sample/1.3/sample-1.3.pom"

	touch_file $old_file_1 $old_date
	touch_file $old_file_2 $old_date
	touch_file $old_file_3 $old_date
	touch_file $new_file_1

	run $testedScript $sample_repos

	# Checks the removal of old files
	[[ ! -f $old_file_1 ]]
	[[ ! -f $old_file_2 ]]
	[[ ! -f $old_file_3 ]]
	[[ ! -d $(dirname $old_file_1) ]]
	[[ ! -d $(dirname $old_file_2) ]]
	[[ ! -d $(dirname $old_file_3) ]]

	# Checks the keeping of new files
	[[ -f $new_file_1 ]]

	# Checks the output
	grep -sF "Remove [3] folders" <<<"$output"
}

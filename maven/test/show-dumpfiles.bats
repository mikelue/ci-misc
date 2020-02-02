#!/usr/bin/env bats

testedScript="$BATS_TEST_DIRNAME/../show-dumpfiles.sh"

cd $BATS_TEST_DIRNAME

@test "Error case: Missed argument \$1" {
    run $testedScript

    [ $status -eq 1 ]

    grep "Needs \"\$1\" arguments" <<<"$output"
}

@test "Error case: Non-existing folder" {
    run $testedScript no-such-folder

    [ $status -eq 1 ]

    grep "Non-existing folder" <<<"$output"
}

@test "Show file names" {
    run $testedScript mvnprj-dump

    [ $status -eq 0 ]

    [[ $(grep -F "Dump file[surefire]" <<<"$output" | wc -l) -eq 2 ]]
    [[ $(grep -F "Dump file[failsafe]" <<<"$output" | wc -l) -eq 2 ]]
}

@test "Show file contents" {
    run $testedScript mvnprj-dump

    [ $status -eq 0 ]

    [[ $(grep -F "dump content" <<<"$output" | wc -l) -eq 4 ]]
}

@test "No target folder" {
    run $testedScript mvnprj-dump-empty

    [ $status -eq 0 ]

    [[ $(grep -F "Dump file" <<<"$output" | wc -l) -eq 0 ]]
}

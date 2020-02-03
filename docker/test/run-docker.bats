#!/usr/bin/env bats

testedScript="$BATS_TEST_DIRNAME/../run-docker.sh"

@test "Missed value of \"-d\" option" {
    run $testedScript -d

    [ $status -eq 1 ]
    grep -q "Usage" <<<"$output"
}
@test "Missed arguments" {
    run $testedScript

    [ $status -eq 1 ]
    grep -q "Usage" <<<"$output"
}
@test "Run hello world" {
    workdir="$BATS_TMPDIR/run-docker.workdir"

    run $testedScript -d "--name ci-misc.run-docker --rm" hello-world:linux $workdir

    [ $status -eq 0 ]
    grep -q "Hello from Docker" <<<"$output"
}

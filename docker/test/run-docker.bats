#!/usr/bin/env bats

testedScript="$BATS_TEST_DIRNAME/../run-docker.sh"

output_result()
{
	echo -e "\n[OUTPUT] run-docker.sh >>>>>\n$1\n<<<<<\n"
} >&3

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

    run $testedScript hello-world:linux $workdir

    output_result "$output"
    [ $status -eq 0 ]
    grep -Fq "Running docker[hello-world:linux]" <<<"$output"
    grep -q "Hello from Docker" <<<"$output"
}

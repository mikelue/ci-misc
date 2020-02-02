#!/usr/bin/env bats

cd $BATS_TEST_DIRNAME

@test "Extract code coverage" {
    run sed -nEf ../extract-code-coverage-jmockit.sed mvnprj-code-coverage/target/coverage-report/index.html

    [ "$output" = "Code coverage: 90.23%" ]
}

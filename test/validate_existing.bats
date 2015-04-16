#!/usr/bin/env bats

load ../src/functions

load test-data
load test-helpers


@test "should fail when facing many missing files" {
    # When:
    run validate_existing files with: 5 out-of: 100

    # Then:
    [ $status -ne 0 ]
}

@test "should fail when facing few missing files" {
    # When:
    run validate_existing files with: 99 out-of: 100

    # Then:
    [ $status -ne 0 ]
}

@test "should fail when facing missing files, tell the user about the issue, and advise of what can be done" {
    # When:
    run validate_existing files with: 0 out-of: 1

    # Then:
    [[ "$output" =~ 'cannot be found' ]] && true || false
    [[ "$output" =~ 'use --verbose to list' ]] && true || false
    [[ "$output" =~ 'use --force to uninstall' ]] && true || false
    [ $status -ne 0 ]
}

@test "should succeed in case no files are missing" {
    # When:
    run validate_existing files with: 10 out-of: 10

    # Then:
    [ -z "$output" ]
    [ $status -eq 0 ]
}

# Local Variables:
# indent-tabs-mode: nil
# End:

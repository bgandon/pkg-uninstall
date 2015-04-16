#!/usr/bin/env bats

load ../src/functions

load test-data
load test-helpers
load test-mocks

# Mock
pkgutil() {
    mocks_save_args "$@"
    return 0
}

@test "should just tell what it would forget, when in dry-run mode" {
    # Given:
    mocks_setup pkgutil

    # When:
    dry_run=yes
    run forget_package com.example.plop.Pkg.ID

    # Then:
    mocks_fetch_args
    [ ${#args[@]} -eq 0 ]

    [ ${#lines[@]} -eq 1 ]
    [ "${lines[0]}" == "Would: pkgutil --forget com.example.plop.Pkg.ID" ]
    [ $status -eq 0 ]
}

@test "should forget package" {
    # Given:
    mocks_setup pkgutil

    # When:
    dry_run=no
    run forget_package com.example.plop.Pkg.ID

    # Then:
    mocks_fetch_args
    [ ${#args[@]} -eq 2 ]
    [ "${args[0]}" == --forget ]
    [ "${args[1]}" == com.example.plop.Pkg.ID ]

    [ -z "$output" ]
    [ $status -eq 0 ]
}

# Local Variables:
# indent-tabs-mode: nil
# End:

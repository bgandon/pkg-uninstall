#!/usr/bin/env bats

load ../src/functions

load test-data
load test-helpers
load test-mocks

# Mock
load mocks/pkgutil--only-dirs

@test "should succeed when finding enough voters to infer prefix" {
    # Given:
    VOTERS_MIN_PATH_ELEMS=2
    VOTERS_MIN_COUNT=6
    mocks_setup pkgutil

    # When:
    run can_infer_prefix com.example.Pkg.ID

    # Then:
    mocks_fetch_args
    [ ${#args[@]} -eq 3 ]
    [ "${args[0]}" == --only-dirs ]
    [ "${args[1]}" == --files ]
    [ "${args[2]}" == com.example.Pkg.ID ]

    [ -z "$output" ]
    [ $status -eq 0 ]
}

@test "should fail when finding foo few voters to infer prefix" {
    # Given:
    VOTERS_MIN_PATH_ELEMS=2
    VOTERS_MIN_COUNT=7
    mocks_setup pkgutil

    # When:
    run can_infer_prefix com.example.Pkg.ID

    # Then:
    mocks_fetch_args
    [ ${#args[@]} -eq 3 ]
    [ "${args[0]}" == --only-dirs ]
    [ "${args[1]}" == --files ]
    [ "${args[2]}" == com.example.Pkg.ID ]

    [ ${#lines[@]} -eq 1 ]
    [[ "${lines[0]}" =~ $(echo "too few voters.* 'com.example.Pkg.ID'.* Aborting.") ]] && true || false
    [ $status -ne 0 ]
}

@test "should fail when finding too few voters with minimum path elements to infer prefix" {
    # Given:
    VOTERS_MIN_PATH_ELEMS=3
    VOTERS_MIN_COUNT=6
    mocks_setup pkgutil

    # When:
    run can_infer_prefix com.example.Pkg.ID

    # Then:
    mocks_fetch_args
    [ ${#args[@]} -eq 3 ]
    [ "${args[0]}" == --only-dirs ]
    [ "${args[1]}" == --files ]
    [ "${args[2]}" == com.example.Pkg.ID ]

    [ ${#lines[@]} -eq 1 ]
    [[ "${lines[0]}" =~ $(echo "too few voters.* 'com.example.Pkg.ID'.* Aborting.") ]] && true || false
    [ $status -ne 0 ]
}

# Local Variables:
# indent-tabs-mode: nil
# End:

#!/usr/bin/env bats

load ../src/functions

load test-data
load test-helpers
load test-mocks

# Mock
load mocks/can_infer_prefix

@test "should succeed when use_prefix_dir=no and can infer prefix" {
    # Given:
    use_prefix_dir=no

    mocks_setup can_infer_prefix
    can_infer_prefix_answers=yes

    # When:
    run can_infer_prefix_dirs_if_necessary com.example.Pkg.ID.1 com.example.Pkg.ID.2

    # Then:
    mocks_fetch_args
    [ ${#args[@]} -eq 2 ]
    [ "${args[0]}" == com.example.Pkg.ID.1 ]
    [ "${args[1]}" == com.example.Pkg.ID.2 ]

    [ -z "$output" ]
    [ $status -eq 0 ]
}

@test "should fail when use_prefix_dir=no but cannot infer prefix" {
    # Given:
    use_prefix_dir=no

    mocks_setup can_infer_prefix
    can_infer_prefix_answers=no

    # When:
    run can_infer_prefix_dirs_if_necessary com.example.Pkg.ID.6 com.example.Pkg.ID.7

    # Then:
    mocks_fetch_args
    [ ${#args[@]} -eq 2 ]
    [ "${args[0]}" == com.example.Pkg.ID.6 ]
    [ "${args[1]}" == com.example.Pkg.ID.7 ]

    [ -z "$output" ]
    [ $status -ne 0 ]
}

@test "should succeed when use_prefix_dir=yes" {
    # Given:
    use_prefix_dir=yes

    mocks_setup can_infer_prefix
    can_infer_prefix_answers=no

    # When:
    run can_infer_prefix_dirs_if_necessary com.example.Pkg.ID.6 com.example.Pkg.ID.7

    # Then:
    mocks_fetch_args
    [ ${#args[@]} -eq 0 ]

    [ -z "$output" ]
    [ $status -eq 0 ]
}

# Local Variables:
# indent-tabs-mode: nil
# End:

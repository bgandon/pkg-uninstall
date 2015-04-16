#!/usr/bin/env bats

load ../src/functions

load test-data
load test-helpers
load test-mocks

# Mock
load mocks/pkgutil--pkg-info

@test "should return OK status when package is found" {
    # Given:
    mocks_setup pkgutil
    pkgutil_finds_package=yes

    # When:
    run are_all_packages_installed com.example.Pkg.ID.1 com.example.Pkg.ID.2

    # Then:
    mocks_fetch_args
    [ ${#args[@]} -eq 4 ]
    [ "${args[0]}" == --pkg-info ]
    [ "${args[1]}" == com.example.Pkg.ID.1 ]
    [ "${args[2]}" == --pkg-info ]
    [ "${args[3]}" == com.example.Pkg.ID.2 ]

    [ $status -eq 0 ]
}

@test "should return KO status when packages are not found" {
    # Given:
    mocks_setup pkgutil
    pkgutil_finds_package=no

    # When:
    run are_all_packages_installed com.example.Pkg.ID.1 com.example.Pkg.ID.7

    # Then:
    mocks_fetch_args
    [ ${#args[@]} -eq 4 ]
    [ "${args[0]}" == --pkg-info ]
    [ "${args[1]}" == com.example.Pkg.ID.1 ]
    [ "${args[2]}" == --pkg-info ]
    [ "${args[3]}" == com.example.Pkg.ID.7 ]

    [ ${#lines[@]} -eq 2 ]
    [ $status -ne 0 ]
}

@test "should fail when packages are not found, telling the user which ones" {
    # Given:
    mocks_setup pkgutil
    pkgutil_finds_package=no

    # When:
    run_with_muted_stdout are_all_packages_installed com.example.Pkg.ID.1 com.example.Pkg.ID.7

    # Then:
    mocks_fetch_args
    [ ${#args[@]} -eq 4 ]

    [ ${#lines[@]} -eq 2 ]
    echo_actual_output
    [[ "${lines[0]}" =~ $(echo "'com.example.Pkg.ID.1' .* not installed.* Aborting.") ]] && true || false
    [[ "${lines[1]}" =~ $(echo "'com.example.Pkg.ID.7' .* not installed.* Aborting.") ]] && true || false
    [ $status -ne 0 ]
}

# Local Variables:
# indent-tabs-mode: nil
# End:

#!/usr/bin/env bats

load ../src/functions

load test-data
load test-helpers


@test "should fail when facing many missing files" {
    # Given:
    do_force=no

    # When:
    run validate_existing files with: 5 out-of: 100

    # Then:
    [ $status -ne 0 ]
}

@test "should fail when facing few missing files" {
    # Given:
    do_force=no

    # When:
    run validate_existing files with: 99 out-of: 100

    # Then:
    [ $status -ne 0 ]
}

@test "should fail when facing missing files, tell the user about the issue, and advise of what can be done" {
    # Given:
    do_force=no

    # When:
    run validate_existing files with: 0 out-of: 1

    # Then:
    [[ "$output" =~ 'cannot be found' ]] && true || false
    [[ "$output" =~ 'use --verbose to list' ]] && true || false
    [[ "$output" =~ 'use --force to uninstall' ]] && true || false
    [ $status -ne 0 ]
}

@test "should succeed in case no files are missing" {
    # Given:
    do_force=no

    # When:
    run validate_existing files with: 10 out-of: 10

    # Then:
    [ -z "$output" ]
    [ $status -eq 0 ]
}

@test "should not fail when --force, even if facing many missing files" {
    # Given:
    do_force=yes

    # When:
    run validate_existing files with: 5 out-of: 100

    # Then:
    [ $status -eq 0 ]
}

@test "should not fail when --force, even if facing few missing files" {
    # Given:
    do_force=yes

    # When:
    run validate_existing files with: 99 out-of: 100

    # Then:
    [ $status -eq 0 ]
}

@test "should continue when facing missing files with --force, warn the user about the issue, and tell why not failing" {
    # Given:
    do_force=yes

    # When:
    run validate_existing files with: 0 out-of: 1

    # Then:
    [[ "$output" =~ 'WARN:' ]] && true || false
    [[ "$output" =~ 'cannot be found' ]] && true || false
    [[ "$output" =~ 'because --force is specified' ]] && true || false
    [ $status -eq 0 ]
}

# Local Variables:
# indent-tabs-mode: nil
# End:

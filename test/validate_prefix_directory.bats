#!/usr/bin/env bats

load ../src/functions

load test-data
load test-helpers

# Mock
sum_and_count_existing() {
    echo -e "42\t6713"
}
# Mock
validate_existing=does-validate
validate_existing() {
    if [ $validate_existing = does-not-validate ]; then
        return 1
    elif [ $validate_existing = does-validate-dirs-only ]; then
        [[ $1 == dirs ]]
        return
    elif [ $validate_existing = does-validate-files-only ]; then
        [[ $1 == files ]]
        return
    fi
    return 0
}
# Mock
list_non_existing() {
    return 0
}

@test "should return KO when not validating dirs nor files" {
    # Given:
    validate_existing=does-not-validate

    # When:
    be_verbose=yes
    run_with_muted_stdout validate_prefix_directory com.example.pkg.id /pfx/dir

    # Then:
    [[ "$output" =~ 'Missing directories:' ]]
    [[ "$output" =~ 'Missing files:' ]]
    [ $status -eq 1 ]
}

@test "should be quiet on stderr when not verbose" {
    # Given:
    validate_existing=does-not-validate

    # When:
    be_verbose=no
    run_with_muted_stdout validate_prefix_directory com.example.pkg.id /pfx/dir

    # Then:
    [ -z "$output" ]
    [ $status -eq 1 ]
}

@test "should return KO when not validating dirs" {
    # Given:
    validate_existing=does-validate-dirs-only

    # When:
    be_verbose=yes
    run_with_muted_stdout validate_prefix_directory com.example.pkg.id /pfx/dir

    # Then:
    [[ ! "$output" =~ 'Missing directories:' ]]
    [[ "$output" =~ 'Missing files:' ]]
    [ $status -eq 1 ]
}

@test "should return KO when not validating files" {
    # Given:
    validate_existing=does-validate-files-only

    # When:
    be_verbose=yes
    run_with_muted_stdout validate_prefix_directory com.example.pkg.id /pfx/dir

    # Then:
    [[ "$output" =~ 'Missing directories:' ]]
    [[ ! "$output" =~ 'Missing files:' ]]
    [ $status -eq 1 ]
}

@test "should return OK when validating files" {
    # Given:
    validate_existing=does-validate

    # When:
    be_verbose=yes
    run_with_muted_stdout validate_prefix_directory com.example.pkg.id /pfx/dir

    # Then:
    [ -z "$output" ]
    [ $status -eq 0 ]
}

# Local Variables:
# indent-tabs-mode: nil
# End:

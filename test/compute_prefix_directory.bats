#!/usr/bin/env bats

load ../src/functions

load test-data
load test-helpers
load test-mocks

# Mock
load mocks/pkgutil--pkg-info

#Mock
infer_prefix_returns=some-prefix
infer_prefix() {
    mocks_save_args "$@"
    if [ $infer_prefix_returns = failure ]; then
        return 42
    else
        echo /inferred/pfx/dir
        return 0
    fi
}

# Mock
defaults_returns=prefix-without-blanks
defaults() {
    mocks_save_args "$@"
    if [ $defaults_returns = prefix-with-blanks ]; then
        echo -e "pfx\t/  dir"
    else
        echo pfx/dir
    fi
}

@test "should return fixed prefix directory" {
    # Given:
    use_prefix_dir=yes
    prefix_dir=/fixed/pfx/dir

    do_infer_prefix_dir=no

    # When:
    run compute_prefix_directory com.example.plop.Pkg.ID

    # Then:
    [ "$output" == /fixed/pfx/dir ]
    [ $status -eq 0 ]
}

@test "should return failure if not able to infer prefix directory" {
    # Given:
    use_prefix_dir=no
    prefix_dir=whatever

    do_infer_prefix_dir=yes
    infer_prefix_returns=failure
    mocks_setup infer_prefix

    # When:
    run compute_prefix_directory com.example.plop.Pkg.ID

    # Then:
    mocks_fetch_args
    [ ${#args[@]} -eq 1 ]
    [ "${args[0]}" == com.example.plop.Pkg.ID ]

    echo actual output: "$output" >&2
    [ -z "$output" ]
    [ $status -eq 42 ]
}

@test "should return inferred prefix directory" {
    # Given:
    use_prefix_dir=no
    prefix_dir=whatever

    do_infer_prefix_dir=yes
    infer_prefix_returns=some-prefix
    mocks_setup infer_prefix

    # When:
    run compute_prefix_directory com.example.plop.Pkg.ID

    # Then:
    mocks_fetch_args
    [ ${#args[@]} -eq 1 ]
    [ "${args[0]}" == com.example.plop.Pkg.ID ]

    [ "$output" == /inferred/pfx/dir ]
    [ $status -eq 0 ]
}

@test "should return prefix directory from receipts database" {
    # Given:
    use_prefix_dir=no
    prefix_dir=whatever

    do_infer_prefix_dir=no
    infer_prefix_returns=whatever

    defaults_returns=prefix-without-blanks
    mocks_setup pkgutil-and-defaults

    # When:
    run compute_prefix_directory com.example.plop.Pkg.ID

    # Then:
    mocks_fetch_args
    [ ${#args[@]} -eq 5 ]
    # when calling 'pkgutil'
    [ "${args[0]}" == --pkg-info ]
    [ "${args[1]}" == com.example.plop.Pkg.ID ]
    # when calling 'defaults'
    [ "${args[2]}" == read ]
    [ "${args[3]}" == /var/db/receipts/com.example.plop.Pkg.ID.plist ]
    [ "${args[4]}" == InstallPrefixPath ]

    [ "$output" == /plop-vol/pfx/dir ]
    [ $status -eq 0 ]
}

@test "should return prefix directory from receipts database, preserving white spaces" {
    # Given:
    use_prefix_dir=no
    prefix_dir=whatever

    do_infer_prefix_dir=no
    infer_prefix_returns=whatever

    defaults_returns=prefix-with-blanks
    mocks_setup pkgutil-and-defaults

    # When:
    run compute_prefix_directory com.example.plop.Pkg.ID

    # Then:
    mocks_fetch_args

    [ "$output" == "$(echo -e "/plop-vol/pfx\t/  dir")" ]
    [ $status -eq 0 ]
}

# Local Variables:
# indent-tabs-mode: nil
# End:

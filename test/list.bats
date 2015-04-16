#!/usr/bin/env bats

load ../src/functions

load test-data
load test-helpers
load test-mocks

# Mock
pkgutil_lists_files=without-blanks
pkgutil() {
    mocks_save_args "$@"
    if [ $pkgutil_lists_files = with-blanks ]; then
        echo -e "$FILES_WITH_BLANKS"
    else
        echo -e "$FILES_NO_SPACE"
    fi
}

@test "should list files" {
    # Given:
    mocks_setup pkgutil
    pkgutil_lists_files=without-blanks

    # When:
    run list files of: com.example.plop.Pkg.ID with: /pfx/dir

    # Then:
    mocks_fetch_args
    [[ ${#args[@]} -eq 3 ]]
    [ "${args[0]}" == --only-files ]
    [ "${args[1]}" == --files ]
    [ "${args[2]}" == com.example.plop.Pkg.ID ]

    [ ${#lines[@]} -eq 3 ]
    [ "${lines[0]}" == /pfx/dir/${L1_F1} ]
    [ "${lines[1]}" == /pfx/dir/${L1_F2} ]
    [ "${lines[2]}" == /pfx/dir/${L1_F3} ]
    [ "$status" -eq 0 ]
}

@test "should preserve whitespaces" {
    # Given:
    mocks_setup pkgutil
    pkgutil_lists_files=with-blanks

    # When:
    run list files of: com.example.plop.Pkg.ID with: "$(echo -e "/whitespace\teager prefix  dir")"

    # Then:
    mocks_fetch_args # we need this anyway to properly cleanup the temporary files and dirs
    # we don't test args because this was is the responsibility of the test above

    [ ${#lines[@]} -eq 3 ]
    [ "${lines[0]}" == "$(echo -e "/whitespace\teager prefix  dir/${L2_F1}")" ]
    [ "${lines[1]}" == "$(echo -e "/whitespace\teager prefix  dir/${L2_F2}")" ]
    [ "${lines[2]}" == "$(echo -e "/whitespace\teager prefix  dir/${L2_F3}")" ]
    [ "$status" -eq 0 ]
}

@test "should list dirs" {
    # Given:
    mocks_setup pkgutil
    pkgutil_lists_files=without-blanks

    # When:
    run list dirs of: com.example.plop.Pkg.ID with: /pfx/dir

    # Then:
    mocks_fetch_args
    [[ ${#args[@]} -eq 3 ]]
    [ "${args[0]}" == --only-dirs ]
    [ "${args[1]}" == --files ]
    [ "${args[2]}" == com.example.plop.Pkg.ID ]

    [ ${#lines[@]} -eq 3 ] # few tests about output because this is the responsibility of the tests above
    [ "$status" -eq 0 ]
}

@test "should list files and dirs" {
    # Given:
    mocks_setup pkgutil
    pkgutil_lists_files=without-blanks

    # When:
    run list files-and-dirs of: com.example.plop.Pkg.ID with: /pfx/dir

    # Then:
    mocks_fetch_args
    [[ ${#args[@]} -eq 2 ]]
    [ "${args[0]}" == --files ]
    [ "${args[1]}" == com.example.plop.Pkg.ID ]

    [ ${#lines[@]} -eq 3 ] # few tests about output because this is the responsibility of the tests above
    [ "$status" -eq 0 ]
}

# Local Variables:
# indent-tabs-mode: nil
# End:

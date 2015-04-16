#!/usr/bin/env bats

load ../src/functions

load test-data
load test-helpers
load test-mocks

# Mock
load mocks/list

# Mock
retain_non_existing() {
    grep -F t
}

@test "should retain existing files" {
    # Given:
    mocks_setup list
    list_files=without-blanks

    # When:
    run list_non_existing files of: com.example.plop.Pkg.ID with: /pfx/dir

    # Then:
    mocks_fetch_args
    [ ${#args[@]} -eq 5 ]
    [ "${args[0]}" == files ]
    [ "${args[2]}" == com.example.plop.Pkg.ID ]
    [ "${args[4]}" == /pfx/dir ]

    [ ${#lines[@]} -eq 2 ]
    [ "${lines[0]}" == /pfx/dir/${L1_F2} ]
    [ "${lines[1]}" == /pfx/dir/${L1_F3} ]
    [ $status -eq 0 ]
}

@test "should retain existing files, supporting white spaces" {
    # Given:
    mocks_setup list
    list_files=with-blanks

    # When:
    run list_non_existing files of: com.example.plop.Pkg.ID with: "/pfx\t/  dir"

    # Then:
    mocks_fetch_args
    [ ${#args[@]} -eq 5 ]

    [ ${#lines[@]} -eq 2 ]
    [ "${lines[0]}" == "$(echo -e "/pfx\t/  dir/${L2_F2}")" ]
    [ "${lines[1]}" == "$(echo -e "/pfx\t/  dir/${L2_F3}")" ]
    [ $status -eq 0 ]
}

# Local Variables:
# indent-tabs-mode: nil
# End:

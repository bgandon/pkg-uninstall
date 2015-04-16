#!/usr/bin/env bats

load ../src/functions

load test-data
load test-helpers
load test-mocks

# Mock
load mock-list

# Mock
does_exist() {
    sed 's/.*t.*/1/; s/^[^1].*/0/;'
}

@test "should count existing files" {
    # Given:
    mocks_setup list
    list_files=without-blanks

    # When:
    run sum_and_count_existing files of: com.example.plop.Pkg.ID with: /pfx/dir

    # Then:
    mocks_fetch_args
    [ ${#args[@]} -eq 5 ]
    [ "${args[0]}" == files ]
    [ "${args[2]}" == com.example.plop.Pkg.ID ]
    [ "${args[4]}" == /pfx/dir ]

    [ "$output" == "$(echo -e "2\t3")" ]
    [ "$status" -eq 0 ]
}

@test "should count existing files, supporting white spaces" {
    # Given:
    mocks_setup list
    list_files=with-blanks

    # When:
    run sum_and_count_existing files of: com.example.plop.Pkg.ID with: "/pfx\t/  dir"

    # Then:
    mocks_fetch_args # we need this anyway to properly cleanup the temporary files and dirs
    # we don't test args because this was is the responsibility of the test above

    [ "$output" == "$(echo -e "2\t3")" ]
    [ "$status" -eq 0 ]
}

# Local Variables:
# indent-tabs-mode: nil
# End:

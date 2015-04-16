#!/usr/bin/env bats

load ../src/functions

load test-data
load test-helpers
load test-mocks

# Mock
load mock-list

@test "should return KO when a file is still there" {
    # Given:
    mocks_setup list
    list_files=without-blanks

    local tmp_dir=$(create_tmp "$L1_F1")
    cd "$tmp_dir"

    # When:
    run are_all_files_removed com.example.plop.Pkg.ID "$tmp_dir"

    # Then:
    mocks_fetch_args
    [ ${#args[@]} -eq 5 ]
    [ "${args[0]}" == files ]
    [ "${args[2]}" == com.example.plop.Pkg.ID ]
    [ "${args[4]}" == "$tmp_dir" ]

    [ $status -ne 0 ]

    # Cleanup:
    rm_tmp "$tmp_dir" "$L1_F1"
    mocks_cleanup
}

@test "should return KO when a file is still there, whatever white spaces in its name and path" {
    # Given:
    list_files=with-blanks

    local tmp_dir=$(create_tmp "$L2_F1")
    cd "$tmp_dir"

    # When:
    run are_all_files_removed com.example.plop.Pkg.ID "$tmp_dir"

    # Then:
    [ $status -ne 0 ]

    # Cleanup:
    rm_tmp "$tmp_dir" "$L2_F1"
}

@test "should return KO when files are still there, telling the user which ones" {
    # Given:
    list_files=without-blanks

    local tmp_dir=$(create_tmp "$L1_F2" "$L1_F3")
    cd "$tmp_dir"

    # When:
    run_with_muted_stdout are_all_files_removed com.example.plop.Pkg.ID "$tmp_dir"

    # Then:
    [ ${#lines[@]} -eq 2 ]
    [[ "${lines[0]}" =~ "could not remove file '$L1_F2'" ]]
    [[ "${lines[1]}" =~ "could not remove file '$L1_F1'" ]]
    [ $status -ne 0 ]

    # Cleanup:
    rm_tmp "$tmp_dir" "$L1_F2" "$L1_F3"
}

@test "should return OK when no files there anymore" {
    # Given:
    list_files=without-blanks

    # When:
    run are_all_files_removed com.example.plop.Pkg.ID /pfx/dir

    # Then:
    [ -z "$output" ]
    [ $status -eq 0 ]
}

# Local Variables:
# indent-tabs-mode: nil
# End:

#!/usr/bin/env bats

load ../src/functions

load test-data
load test-helpers

@test "should tell file1 and file2 exist" {
    # Given:
    local tmp_dir=$(create_tmp "$L2_F1" "$L2_F2")
    cd "$tmp_dir"

    # When:
    run does_exist <<EOF
$(echo -e "$FILES_WITH_BLANKS")
EOF

    # Then:
    [ "$output" == "$(echo -e "1\n1\n0")" ]
    [ $status -eq 0 ]

    # Cleanup:
    rm_tmp "$tmp_dir" "$L2_F1" "$L2_F2"
}

@test "should tell file1 and file3 exist" {
    # Given:
    local tmp_dir=$(create_tmp "$L2_F1" "$L2_F3")
    cd "$tmp_dir"

    # When:
    run does_exist <<EOF
$(echo -e "$FILES_WITH_BLANKS")
EOF

    # Then:
    [ "$output" == "$(echo -e "1\n0\n1")" ]
    [ $status -eq 0 ]

    # Cleanup:
    rm_tmp "$tmp_dir" "$L2_F1" "$L2_F3"
}

@test "should tell only file2 exists" {
    # Given:
    local tmp_dir=$(create_tmp "$L2_F2")
    cd "$tmp_dir"

    # When:
    run does_exist <<EOF
$(echo -e "$FILES_WITH_BLANKS")
EOF

    # Then:
    [ "$output" == "$(echo -e "0\n1\n0")" ]
    [ $status -eq 0 ]

    # Cleanup:
    rm_tmp "$tmp_dir" "$L2_F2"
}

@test "should tell only file3 exists" {
    # Given:
    local tmp_dir=$(create_tmp "$L2_F3")
    cd "$tmp_dir"

    # When:
    run does_exist <<EOF
$(echo -e "$FILES_WITH_BLANKS")
EOF

    # Then:
    [ "$output" == "$(echo -e "0\n0\n1")" ]
    [ $status -eq 0 ]

    # Cleanup:
    rm_tmp "$tmp_dir" "$L2_F3"
}

# Local Variables:
# indent-tabs-mode: nil
# End:

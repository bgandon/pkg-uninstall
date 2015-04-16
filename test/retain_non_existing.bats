#!/usr/bin/env bats

load ../src/functions

load test-data
load test-helpers

@test "should retain last file of the list" {
    # Given:
    local tmp_dir=$(create_tmp "$L2_F1" "$L2_F2")
    cd "$tmp_dir"

    # When:
    run retain_non_existing <<EOF
$(echo -e "$FILES_WITH_BLANKS")
EOF

    # Then:
    [ "$output" == "$(echo -e "$L2_F3")" ]

    # Cleanup:
    rm_tmp "$tmp_dir" "$L2_F1" "$L2_F2"
}

@test "should retain first and last files of the list" {
    # Given:
    local tmp_dir=$(create_tmp "$L2_F1" "$L2_F3")
    cd "$tmp_dir"

    # When:
    run retain_non_existing <<EOF
$(echo -e "$FILES_WITH_BLANKS")
EOF

    # Then:
    [ "$output" == "$(echo -e "$L2_F2")" ]

    # Cleanup:
    rm_tmp "$tmp_dir" "$L2_F1" "$L2_F3"
}

@test "should retain file in the middle of the list" {
    # Given:
    local tmp_dir=$(create_tmp "$L2_F2")
    cd "$tmp_dir"

    # When:
    run retain_non_existing <<EOF
$(echo -e "$FILES_WITH_BLANKS")
EOF

    # Then:
    [ "$output" == "$(echo -e "${L2_F1}\n${L2_F3}")" ]

    # Cleanup:
    rm_tmp "$tmp_dir" "$L2_F2"
}

@test "should retain first files of the list" {
    # Given:
    local tmp_dir=$(create_tmp "$L2_F3")
    cd "$tmp_dir"

    # When:
    run retain_non_existing <<EOF
$(echo -e "$FILES_WITH_BLANKS")
EOF

    # Then:
    [ "$output" == "$(echo -e "${L2_F1}\n${L2_F2}")" ]

    # Cleanup:
    rm_tmp "$tmp_dir" "$L2_F3"
}

# Local Variables:
# indent-tabs-mode: nil
# End:

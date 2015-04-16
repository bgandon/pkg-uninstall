#!/usr/bin/env bats

load ../src/functions

load test-data

@test "should retain no files, when none has enough path elements" {
    # When:
    run retain_dirs_with_min_path_elems 4 <<EOF
$(echo -e "$FILES_WITH_BLANKS")
EOF
    # Then:
    [ -z "$output" ]
    [ $status -eq 0 ]
}

@test "should retain only files with enough path elements" {
    # When:
    run retain_dirs_with_min_path_elems 2 <<EOF
$(echo -e "$FILES_NO_SPACE")
EOF
    # Then:
    [ ${#lines[@]} -eq 2 ]
    [ "${lines[0]}" == $L1_F1 ]
    [ "${lines[1]}" == $L1_F2 ]
    [ $status -eq 0 ]
}

@test "should retain only files with enough path elements, preserving white spaces" {
    # When:
    run retain_dirs_with_min_path_elems 2 <<EOF
$(echo -e "$FILES_WITH_BLANKS")
EOF
    # Then:
    [ ${#lines[@]} -eq 2 ]
    [ "${lines[0]}" == "$(echo -e "$L2_F1")" ]
    [ "${lines[1]}" == "$(echo -e "$L2_F2")" ]
    [ $status -eq 0 ]
}

@test "should retain all files, when all have enough path elements" {
    # When:
    run retain_dirs_with_min_path_elems 1 <<EOF
$(echo -e "$FILES_NO_SPACE")
EOF
    # Then:
    [ "$output" == "$(echo -e "$FILES_NO_SPACE")" ]
    [ $status -eq 0 ]
}

@test "should retain all files, when all have enough path elements, preserving blanks" {
    # When:
    run retain_dirs_with_min_path_elems 1 <<EOF
$(echo -e "$FILES_WITH_BLANKS")
EOF
    # Then:
    [ "$output" == "$(echo -e "$FILES_WITH_BLANKS")" ]
    [ $status -eq 0 ]
}

# Local Variables:
# indent-tabs-mode: nil
# End:

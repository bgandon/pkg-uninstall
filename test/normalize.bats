#!/usr/bin/env bats

load ../src/functions

load test-data

@test "should not affect correct paths when normalizing" {
    # When:
    run normalize <<EOF
$(echo -e "$FILES_WITH_BLANKS")
EOF

    # Then:
    [ "$output" == "$(echo -e "$FILES_WITH_BLANKS")" ]
    [ $status -eq 0 ]
}

@test "should contract multiple directory separators when normalizing" {
    # When:
    run normalize <<EOF
$(echo -e "$FILES_WITH_MULTIPLE_DIR_SEPS")
EOF

    # Then:
    [ "$output" == "$(echo -e "$FILES_WITH_SINGLE_DIR_SEPS")" ]
    [ $status -eq 0 ]
}

# Local Variables:
# indent-tabs-mode: nil
# End:

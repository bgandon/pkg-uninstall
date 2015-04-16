#!/usr/bin/env bats

load ../src/functions

load test-data
load test-helpers

@test "should reverse lines preserving blanks" {
    # When:
    run reverse <<EOF
$(echo -e "${L2_F1}\n${L2_F2}\n${L2_F3}")
EOF

    # Then:
    echo_actual_output
    [ "$output" == "$(echo -e "${L2_F3}\n${L2_F2}\n${L2_F1}")" ]
    [ $status -eq 0 ]
}

# Local Variables:
# indent-tabs-mode: nil
# End:

#!/usr/bin/env bats

load ../src/functions

load test-data

@test "should prepend string to each lines, supporting all sed reserved chars, and preserving blanks" {
    # Given
    PFX='\//paf\\/ bim// [ /// * . ] poum]'

    # When:
    run prepend_string "$PFX" <<EOF
$(echo -e "$FILES_WITH_BLANKS")
EOF

    # Then:
    [ ${#lines[@]} -eq 3 ]
    [ "${lines[0]}" == "${PFX}$(echo -e "${L2_F1}")" ]
    [ "${lines[1]}" == "${PFX}$(echo -e "${L2_F2}")" ]
    [ "${lines[2]}" == "${PFX}$(echo -e "${L2_F3}")" ]
    [ $status -eq 0 ]
}

# Local Variables:
# indent-tabs-mode: nil
# End:

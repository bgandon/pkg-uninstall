#!/usr/bin/env bats

load ../src/functions

load test-data

@test "should reverse lines preserving blanks" {
    result=$(echo -e "$FILES_WITH_BLANKS" \
                    | reverse)
    [ "$result" == "$(echo -e "${L2_F3}\n${L2_F2}\n${L2_F1}")" ]
}

# Local Variables:
# indent-tabs-mode: nil
# End:

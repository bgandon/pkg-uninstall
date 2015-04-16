#!/usr/bin/env bats

load ../src/functions


@test "should sum and count with mixed 1 and 0, ending with 0" {
    # When:
    result=$(echo -e "1\n1\n0\n1\n0" \
                    | sum_and_count)

    # Then:
    [ "$result" == "$(echo -e "3\t5")" ]
}

@test "should sum and count with mixed 1 and 0, ending with 1" {
    # When:
    result=$(echo -e "1\n0\n0\n1\n1\n1" \
                    | sum_and_count)

    # Then:
    [ "$result" == "$(echo -e "4\t6")" ]
}

@test "should sum and count properly with all 1" {
    # When:
    result=$(echo -e "1\n1\n1" \
                    | sum_and_count)

    # Then:
    [ "$result" == "$(echo -e "3\t3")" ]
}

@test "should sum and count properly with all 0" {
    # When:
    result=$(echo -e "0\n0\n0\n0" \
                    | sum_and_count)

    # Then:
    [ "$result" == "$(echo -e "0\t4")" ]
}

# Local Variables:
# indent-tabs-mode: nil
# End:

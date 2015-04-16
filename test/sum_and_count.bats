#!/usr/bin/env bats

load ../src/functions

@test "should sum and count with mixed 1 and 0, ending with 0" {
    # When:
    run sum_and_count <<EOF
1
1
0
1
0
EOF

    # Then:
    [ "$output" == "$(echo -e "3\t5")" ]
}

@test "should sum and count with mixed 1 and 0, ending with 1" {
    # When:
    run sum_and_count <<EOF
1
0
0
1
1
1
EOF

    # Then:
    [ "$output" == "$(echo -e "4\t6")" ]
}

@test "should sum and count properly with all 1" {
    # When:
    run sum_and_count <<EOF
1
1
1
EOF

    # Then:
    [ "$output" == "$(echo -e "3\t3")" ]
}

@test "should sum and count properly with all 0" {
    # When:
    run sum_and_count <<EOF
0
0
0
0
EOF

    # Then:
    [ "$output" == "$(echo -e "0\t4")" ]
}

# Local Variables:
# indent-tabs-mode: nil
# End:

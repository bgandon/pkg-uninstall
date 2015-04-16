#!/usr/bin/env bats

load ../src/functions

load test-data
load test-helpers

@test "should exit with status 10 when encountering illegal votes count" {
    # When:
    run retain_single_unanimous_winner_only <<EOF
3	3	/plip
3	1	/plop
3	4	/boum
EOF

    # Then:
    [ -z "$output" ]
    [ $status -eq 10 ]
}

@test "should exit with status 11 when encountering many unanimous winners" {
    # When:
    run retain_single_unanimous_winner_only <<EOF
3	3	/plip
3	3	/plip-plip
3	1	/plop
EOF

    # Then:
    [ -z "$output" ]
    [ $status -eq 11 ]
}

@test "should exit with status 12 when encountering no unanimous winners" {
    # When:
    run retain_single_unanimous_winner_only <<EOF
3	2	/plip
3	1	/plaf
3	1	/plop
EOF

    # Then:
    [ -z "$output" ]
    [ $status -eq 12 ]
}

@test "should print the unanimous winner if there is only one, preserving white spaces" {
    # When:
    run retain_single_unanimous_winner_only <<EOF
3	3	/pl  ip
3	2	/plaf
3	1	/plop
EOF

    # Then:
    [ "$output" == "/pl  ip" ] # two spaces should be preserved
    [ $status -eq 0 ]
}

@test "should print the unanimous winner if there is only one, accepting spaces instead of tabs" {
    # When:
    run retain_single_unanimous_winner_only <<EOF
3   3   /pl  ip
3   2   /plaf
3   1   /plop
EOF

    # Then:
    [ "$output" == "/pl  ip" ] # two spaces should be preserved
    [ $status -eq 0 ]
}

@test "should the unanimous winner if there is only one, even when lines are not sorted, preserving white spaces" {
    # When:
    run retain_single_unanimous_winner_only <<EOF
3	2	/plip
3	1	/plaf
3	3	/plo	p
EOF

    # Then:
    [ "$output" == "/plo	p" ] # a tab should be preserved
    [ $status -eq 0 ]
}

# Local Variables:
# indent-tabs-mode: nil
# End:

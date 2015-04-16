#!/usr/bin/env bats

load ../src/functions

load test-data

@test "should escape each lines so that it can be injected in a sed regex replacement command" {
    # When:
    run sed_escape <<EOF
bs\ fs/ dot. star* brackets[ ]
' \\
" \ '
EOF

    # Then:
    [ ${#lines[@]} -eq 3 ]
    [ "${lines[0]}" == 'bs\\ fs\/ dot\. star\* brackets\[ \]' ]
    [ "${lines[1]}" == \'' \\' ]
    [ "${lines[2]}" == '" \\ '\' ]
    [ $status -eq 0 ]
}

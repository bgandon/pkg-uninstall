#!/usr/bin/env bats

load ../src/functions

load test-data
load test-helpers

# Mock
pkgutil() {
    return 0
}
VOTERS_MIN_PATH_ELEMS=0
VOTERS_MIN_COUNT=0
# Mock
votes_for_prefix_candidates() {
    cat <<EOF
3	3	/plip  plop
3	1	/plop
EOF
}
# Mock
retain_single_unanimous_winner_only() {
    if [ $votes_results = illegal-counts ]; then
        return 10
    elif [ $votes_results = too-many-unanimous-winners ]; then
        return 11
    elif [ $votes_results = no-unanimous-winner ]; then
        return 12
    else
        echo '/plip  plop'
        return 0
    fi
}

@test "should fail when facing illegal vote results" {
    # Given:
    votes_results=illegal-counts

    # When:
    run_with_muted_stdout infer_prefix com.example.Pkg.ID

    # Then:
    [[ "$output" =~ "illegal result" ]] && true || false
    [ $status -ne 0 ]
}

@test "should fail when facing too many unanimous winners" {
    # Given:
    votes_results=too-many-unanimous-winners

    # When:
    run_with_muted_stdout infer_prefix com.example.Pkg.ID

    # Then:
    [[ "$output" =~ "too many" ]] && true || false
    [ $status -ne 0 ]
}

@test "should fail when facing no unanimous winner" {
    # Given:
    votes_results=no-unanimous-winner

    # When:
    run_with_muted_stdout infer_prefix com.example.Pkg.ID

    # Then:
    [[ "$output" =~ "cannot infer" ]] && true || false
    [ $status -ne 0 ]
}

@test "should print the unanimous winner when there is only one" {
    # Given:
    votes_results=one-unanimous-winner

    # When:
    run infer_prefix com.example.Pkg.ID

    # Then:
    [ "$output" == "/plip  plop" ]
    [ $status -eq 0 ]
}

# Local Variables:
# indent-tabs-mode: nil
# End:

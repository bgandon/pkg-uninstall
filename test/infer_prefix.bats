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
votes_for_prefix_candidates() {
    cat <<EOF
3   3   /plip  plop
3   1   /plop
EOF
}
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

@test "should return KO facing illegal vote results" {
    # Given:
    votes_results=illegal-counts

    # When:
    run_with_muted_stdout infer_prefix com.example.Pkg.ID

    # Then:
    [[ "$output" =~ "illegal result" ]]
    [ "$status" -ne 0 ]
}

@test "should return KO facing too many unanimous winners" {
    # Given:
    votes_results=too-many-unanimous-winners

    # When:
    run_with_muted_stdout infer_prefix com.example.Pkg.ID

    # Then:
    [[ "$output" =~ "too many" ]]
    [ "$status" -ne 0 ]
}

@test "should return KO facing no unanimous winner" {
    # Given:
    votes_results=no-unanimous-winner

    # When:
    run_with_muted_stdout infer_prefix com.example.Pkg.ID

    # Then:
    [[ "$output" =~ "cannot infer" ]]
    [ "$status" -ne 0 ]
}

@test "should the unanimous winner when there is only one" {
    # Given:
    votes_results=one-unanimous-winner

    # When:
    run infer_prefix com.example.Pkg.ID

    # Then:
    [[ "$output" =~ "/plip  plop" ]]
    [ "$status" -eq 0 ]
}

# Local Variables:
# indent-tabs-mode: nil
# End:

#!/usr/bin/env bats

load ../src/functions

load test-data
load test-helpers
load test-mocks

@test "should list votes for prefix in descending order of results" {
    # Given:
    local tmp_dir=$(create_tmp "bam\tpoum/$L2_F1" "bam\tpoum/$L2_F2" \
                               "pif paf/$L2_F1" "pif paf/$L2_F2" "pif paf/$L2_F3")
    cd "$tmp_dir"

    bin_dir=$(mocks_create_bin "$tmp_dir" locate - <<EOF
#!/bin/sh
for str in "\$@"; do
#   echo "/boum\$str"
    find . -path "*\${str}*" -print | sed -e 's/^\.//'
done
EOF
    )
    local old_PATH="$PATH"
    export PATH="$bin_dir:$PATH"

    # When:
    run_with_muted_stderr votes_for_prefix_candidates <<EOF
$(echo -e "$FILES_WITH_BLANKS")
EOF

    # Then:
    [ ${#lines[@]} -eq 2 ]
    [ "${lines[0]}" == "$(echo -e "3\t3\t/pif paf")" ]
    [ "${lines[1]}" == "$(echo -e "3\t2\t/bam\tpoum")" ]
    [ $status -eq 0 ]

    # Cleanup:
    mocks_cleanup_bin "$old_PATH" locate

    rm_tmp "$tmp_dir" \
           "bam\tpoum/$L2_F1" "bam\tpoum/$L2_F2" \
           "pif paf/$L2_F1" "pif paf/$L2_F2" "pif paf/$L2_F3"
}

# Local Variables:
# indent-tabs-mode: nil
# End:

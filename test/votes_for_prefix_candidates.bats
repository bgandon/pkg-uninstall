#!/usr/bin/env bats

load ../src/functions

load test-data
load test-helpers

mocks_create_bin() {
    local bin_name="$1"
    local src="$2"

    if [ ! -d bin ]; then
       mkdir bin
    fi
    cat "$src" > "bin/${bin_name}"
    chmod a+x "bin/${bin_name}"
}

mocks_cleanup_bin() {
    local bin_name="$1"
    rm "bin/${bin_name}"
    rmdir bin
}

@test "should list votes for prefix in descending order of results" {
    # Given:
    local tmp_dir=$(create_tmp "bam\tpoum/$L2_F1" "bam\tpoum/$L2_F2" \
                               "pif paf/$L2_F1" "pif paf/$L2_F2" "pif paf/$L2_F3")
    cd "$tmp_dir"

    mocks_create_bin locate - <<EOF
#!/bin/sh
for str in "\$@"; do
#   echo "/boum\$str"
    find . -path "*\${str}*" -print | sed -e 's/^\.//'
done
EOF

    local old_PATH="$PATH"
    export PATH="$tmp_dir/bin:$PATH"

    # When:
    # NOTE: here we use the 'heredoc' syntax, because using a pipe
    # prevents run() from returning its variables: $output, $lines[], etc.
    run_with_muted_stderr votes_for_prefix_candidates <<EOF
$(echo -e "$FILES_WITH_BLANKS")
EOF

    # Then:
#   echo actual output: >&2
#   cat -t >&2 <<EOF
#$output
#EOF
    [ ${#lines[@]} -eq 2 ]
    [ "${lines[0]}" == "$(echo -e "3\t3\t/pif paf")" ]
    [ "${lines[1]}" == "$(echo -e "3\t2\t/bam\tpoum")" ]
    [ "$status" -eq 0 ]

    # Cleanup:
    export PATH="$old_PATH"

    mocks_cleanup_bin locate

    rm_tmp "$tmp_dir" \
           "bam\tpoum/$L2_F1" "bam\tpoum/$L2_F2" \
           "pif paf/$L2_F1" "pif paf/$L2_F2" "pif paf/$L2_F3"
}

# Local Variables:
# indent-tabs-mode: nil
# End:

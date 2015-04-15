#!/usr/bin/env bats

load ../src/functions

load test-data
load test-helpers

@test "should tell file1 and file2 exist" {
	# Given:
	local tmp_dir=$(create_tmp "$L2_F1" "$L2_F2")
	cd "$tmp_dir"

	# When:
	result=$(echo -e "$FILES_WITH_BLANKS" \
					| does_exist)

	# Then:
	[ "$result" == "$(echo -e "1\n1\n0")" ]

	# Cleanup:
	rm_tmp "$tmp_dir" "$L2_F1" "$L2_F2"
}

@test "should tell file1 and file3 exist" {
	# Given:
	local tmp_dir=$(create_tmp "$L2_F1" "$L2_F3")
	cd "$tmp_dir"

	# When:
	result=$(echo -e "$FILES_WITH_BLANKS" \
					| does_exist)

	# Then:
	[ "$result" == "$(echo -e "1\n0\n1")" ]

	# Cleanup:
	rm_tmp "$tmp_dir" "$L2_F1" "$L2_F3"
}

@test "should tell only file2 exists" {
	# Given:
	local tmp_dir=$(create_tmp "$L2_F2")
	cd "$tmp_dir"

	# When:
	result=$(echo -e "$FILES_WITH_BLANKS" \
					| does_exist)

	# Then:
	[ "$result" == "$(echo -e "0\n1\n0")" ]

	# Cleanup:
	rm_tmp "$tmp_dir" "$L2_F2"
}

@test "should tell only file3 exists" {
	# Given:
	local tmp_dir=$(create_tmp "$L2_F3")
	cd "$tmp_dir"

	# When:
	result=$(echo -e "$FILES_WITH_BLANKS" \
					| does_exist)

	# Then:
	[ "$result" == "$(echo -e "0\n0\n1")" ]

	# Cleanup:
	rm_tmp "$tmp_dir" "$L2_F3"
}


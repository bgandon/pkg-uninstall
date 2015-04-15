#!/usr/bin/env bats

load ../src/functions

load test-data

# NO SPACE

@test "should retain 0 files with 4 path elems" {
	result=$(echo -e "$FILES_NO_SPACE" \
					| retain_dirs_with_min_path_elems 4)
	[ -z "$result" ]
}

@test "should retain 1 file with 3+ path elems" {
	result=$(echo -e "$FILES_NO_SPACE" \
					| retain_dirs_with_min_path_elems 3)
	[ "$result" == $L1_F1 ]
}

@test "should retain 2 files with 2+ path elems" {
	result=$(echo -e "$FILES_NO_SPACE" \
					| retain_dirs_with_min_path_elems 2)
	[ "$result" == "$(echo -e "${L1_F1}\n${L1_F2}")" ]
}

@test "should retain all 3 files with 1+ path elems" {
	result=$(echo -e "$FILES_NO_SPACE" \
					| retain_dirs_with_min_path_elems 1)
	[ "$result" == "$(echo -e "$FILES_NO_SPACE")" ]
}

# WITH BLANKS

@test "should retain 0 files with 4 path elems that include blanks" {
	result=$(echo -e "$FILES_WITH_BLANKS" \
					| retain_dirs_with_min_path_elems 4)
	[ -z "$result" ]
}

@test "should retain 1 file with 3+ path elems that include blanks" {
	result=$(echo -e "$FILES_WITH_BLANKS" \
					| retain_dirs_with_min_path_elems 3)
	[ "$result" == "$(echo -e "$L2_F1")" ]
}

@test "should retain 2 files with 2+ path elems that include blanks" {
	result=$(echo -e "$FILES_WITH_BLANKS" \
					| retain_dirs_with_min_path_elems 2)
	[ "$result" == "$(echo -e "${L2_F1}\n${L2_F2}")" ]
}

@test "should retain all 3 files with 1+ path elems that include blanks" {
	result=$(echo -e "$FILES_WITH_BLANKS" \
					| retain_dirs_with_min_path_elems 1)
	[ "$result" == "$(echo -e "$FILES_WITH_BLANKS")" ]
}


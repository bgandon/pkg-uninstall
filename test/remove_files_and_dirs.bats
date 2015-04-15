#!/usr/bin/env bats

load ../src/functions

load test-data
load test-helpers
load test-mocks

# Mock
load mock-list

# Mock
apply_cmd() {
	if [ $dry_run = yes ]; then
		set Would: "$@"
	fi
	tr '\n' '\0' \
		| xargs -0 -n 1 echo "$@" | tee -a "$MOCK_OUT"
}

@test "should remove files, then dirs, in reverse package order" {
	# Given:
	mocks_setup list-and-apply_cmd
	list_files=without-blanks

	# When:
	dry_run=no
	run remove_files_and_dirs com.example.plop.Pkg.ID /pfx/dir

	# Then:
	mocks_fetch_args
	[[ ${#args[@]} -eq 6 ]]
	[ "${args[0]}" == files ]
	[ "${args[2]}" == com.example.plop.Pkg.ID ]
	[ "${args[4]}" == /pfx/dir ]
	[ "${args[5]}" == dirs ]
	[ "${args[7]}" == com.example.plop.Pkg.ID ]
	[ "${args[9]}" == /pfx/dir ]

	[ ${#mocks_lines[@]} -eq 6 ]
	[ "${mocks_lines[0]}" == "rm /pfx/dir/${L1_F3}" ]
	[ "${mocks_lines[1]}" == "rm /pfx/dir/${L1_F2}" ]
	[ "${mocks_lines[2]}" == "rm /pfx/dir/${L1_F1}" ]
	[ "${mocks_lines[3]}" == "rmdir /pfx/dir/${L1_F3}" ]
	[ "${mocks_lines[4]}" == "rmdir /pfx/dir/${L1_F2}" ]
	[ "${mocks_lines[5]}" == "rmdir /pfx/dir/${L1_F1}" ]
	[ "$status" -eq 0 ]
}

@test "should remove files, then dirs, in reverse package order, preserving wite spaces" {
	# Given:
	mocks_setup list-and-apply_cmd
	list_files=with-blanks

	# When:
	dry_run=no
	run remove_files_and_dirs com.example.plop.Pkg.ID "/pfx\t/  dir"

	# Then:
	mocks_fetch_args
	[ ${#mocks_lines[@]} -eq 6 ]
	[ "${mocks_lines[0]}" == "$(echo -e "rm /pfx\t/  dir/${L2_F3}")" ]
	[ "${mocks_lines[1]}" == "$(echo -e "rm /pfx\t/  dir/${L2_F2}")" ]
	[ "${mocks_lines[2]}" == "$(echo -e "rm /pfx\t/  dir/${L2_F1}")" ]
	[ "${mocks_lines[3]}" == "$(echo -e "rmdir /pfx\t/  dir/${L2_F3}")" ]
	[ "${mocks_lines[4]}" == "$(echo -e "rmdir /pfx\t/  dir/${L2_F2}")" ]
	[ "${mocks_lines[5]}" == "$(echo -e "rmdir /pfx\t/  dir/${L2_F1}")" ]
	[ "$status" -eq 0 ]
}

@test "should not actually remove files but just explain, when in dry-run mode" {
	# Given:
	mocks_setup list-and-apply_cmd
	list_files=without-blanks

	# When:
	dry_run=yes
	run remove_files_and_dirs com.example.plop.Pkg.ID /pfx/dir

	# Then:
	mocks_fetch_args
	[[ ${#args[@]} -eq 6 ]]
	[ "${args[0]}" == files ]
	[ "${args[2]}" == com.example.plop.Pkg.ID ]
	[ "${args[4]}" == /pfx/dir ]
	[ "${args[5]}" == dirs ]
	[ "${args[7]}" == com.example.plop.Pkg.ID ]
	[ "${args[9]}" == /pfx/dir ]

	[ ${#lines[@]} -eq 6 ]
	[ "${lines[0]}" == "Would: rm /pfx/dir/${L1_F3}" ]
	[ "${lines[1]}" == "Would: rm /pfx/dir/${L1_F2}" ]
	[ "${lines[2]}" == "Would: rm /pfx/dir/${L1_F1}" ]
	[ "${lines[3]}" == "Would: rmdir /pfx/dir/${L1_F3}" ]
	[ "${lines[4]}" == "Would: rmdir /pfx/dir/${L1_F2}" ]
	[ "${lines[5]}" == "Would: rmdir /pfx/dir/${L1_F1}" ]
	[ "$status" -eq 0 ]
}

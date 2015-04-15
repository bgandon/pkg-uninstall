#!/usr/bin/env bats

load ../src/functions

load test-data
load test-helpers
load test-mocks

# Mock
pkgutil() {
	mocks_save_args "$@"
	echo -e "$FILES_WITH_BLANKS"
	echo -e "$FILES_WITH_BLANKS"
	echo -e "$FILES_WITH_BLANKS"
}

@test "should find enough voters to infer prefix" {
	# Given:
	VOTERS_MIN_PATH_ELEMS=2
	VOTERS_MIN_COUNT=6
	mocks_setup pkgutil

	# When:
	run can_infer_prefix com.example.Pkg.ID

	# Then:
	mocks_fetch_args
	[ "${args[0]}" == --only-dirs ]
	[ "${args[1]}" == --files ]
	[ "${args[2]}" == com.example.Pkg.ID ]

	[ "$status" -eq 0 ]
}

@test "should find foo few voters to infer prefix" {
	# Given:
	VOTERS_MIN_PATH_ELEMS=2
	VOTERS_MIN_COUNT=7
	mocks_setup pkgutil

	# When:
	run can_infer_prefix com.example.Pkg.ID

	# Then:
	mocks_fetch_args
	[ "${args[0]}" == --only-dirs ]
	[ "${args[1]}" == --files ]
	[ "${args[2]}" == com.example.Pkg.ID ]

	[[ "${lines[0]}" =~ "too few voters.* 'com.example.Pkg.ID'.* Aborting." ]]
	[ "$status" -ne 0 ]
}

@test "should find too few voters with minimum path elements to infer prefix" {
	# Given:
	VOTERS_MIN_PATH_ELEMS=3
	VOTERS_MIN_COUNT=6
	mocks_setup pkgutil

	# When:
	run can_infer_prefix com.example.Pkg.ID

	# Then:
	mocks_fetch_args
	[ "${args[0]}" == --only-dirs ]
	[ "${args[1]}" == --files ]
	[ "${args[2]}" == com.example.Pkg.ID ]

	[[ "${lines[0]}" =~ "too few voters.* 'com.example.Pkg.ID'.* Aborting." ]]
	[ "$status" -ne 0 ]
}

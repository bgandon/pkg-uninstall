#!/usr/bin/env bats

load ../src/functions

load test-data
load test-helpers
load test-mocks

# Mock
can_infer_prefix_answers=yes
can_infer_prefix() {
	mocks_save_args "$@"
	if [ $can_infer_prefix_answers = yes ]; then
		return 0
	else
		return 1
	fi
}

@test "should return OK status when use_prefix_dir=no and can infer prefix" {
	# Given:
	use_prefix_dir=no

	mocks_setup can_infer_prefix
	can_infer_prefix_answers=yes

	# When:
	run assert_can_infer_prefix_dirs_if_necessary com.example.Pkg.ID.1 com.example.Pkg.ID.2

	# Then:
	mocks_fetch_args
	[ "${#args[@]}" == 2 ]
	[ "${args[0]}" == com.example.Pkg.ID.1 ]
	[ "${args[1]}" == com.example.Pkg.ID.2 ]

	[ "$status" -eq 0 ]
}

@test "should return KO status when use_prefix_dir=no but cannot infer prefix" {
	# Given:
	use_prefix_dir=no

	mocks_setup can_infer_prefix
	can_infer_prefix_answers=no

	# When:
	run assert_can_infer_prefix_dirs_if_necessary com.example.Pkg.ID.6 com.example.Pkg.ID.7

	# Then:
	mocks_fetch_args
	[ "${#args[@]}" == 2 ]
	[ "${args[0]}" == com.example.Pkg.ID.6 ]
	[ "${args[1]}" == com.example.Pkg.ID.7 ]

	[ "$status" -ne 0 ]
}

@test "should return OK status when use_prefix_dir=yes" {
	# Given:
	use_prefix_dir=yes

	mocks_setup can_infer_prefix
	can_infer_prefix_answers=no

	# When:
	run assert_can_infer_prefix_dirs_if_necessary com.example.Pkg.ID.6 com.example.Pkg.ID.7

	# Then:
	mocks_fetch_args
	[ "${#args[@]}" == 0 ]

	[ "$status" -eq 0 ]
}

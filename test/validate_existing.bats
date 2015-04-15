#!/usr/bin/env bats

load ../src/functions

load test-data
load test-helpers


@test "should return KO when facing many non-existing files" {
	# When:
	run validate_existing files with: 5 out-of: 100

	# Then:
	[ $status -eq 1 ]
}

@test "should return KO when facing many few files" {
	# When:
	run validate_existing files with: 99 out-of: 100

	# Then:
	[ $status -eq 1 ]
}

@test "should tell the user about the issue, and advise of what can be done" {
	# When:
	run validate_existing files with: 0 out-of: 1

	# Then:
	[[ "$output" =~ 'cannot be found' ]]
	[[ "$output" =~ 'use --verbose to list' ]]
	[[ "$output" =~ 'use --force to uninstall' ]]
	[ $status -eq 1 ]
}

@test "should return OK when files are present" {
	# When:
	run validate_existing files with: 10 out-of: 10

	# Then:
	[ -z "$output" ]
	[ $status -eq 0 ]
}

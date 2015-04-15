#!/usr/bin/env bats

load ../src/functions

load test-data
load test-helpers
load test-mocks

# Mock
pkgutil_finds_package=yes
pkgutil() {
	mocks_save_args "$@"
	if [ $pkgutil_finds_package = yes ]; then
		return 0
	else
		return 1
	fi
}

@test "should return OK status when package is found" {
	# Given:
	mocks_setup pkgutil
	pkgutil_finds_package=yes

	# When:
	run assert_all_packages_are_installed com.example.Pkg.ID.1 com.example.Pkg.ID.2

	# Then:
	mocks_fetch_args
	[ "${args[0]}" == --pkg-info ]
	[ "${args[1]}" == com.example.Pkg.ID.1 ]
	[ "${args[2]}" == --pkg-info ]
	[ "${args[3]}" == com.example.Pkg.ID.2 ]

	[ "$status" -eq 0 ]
}

@test "should return KO status when package is not found" {
	# Given:
	mocks_setup pkgutil
	pkgutil_finds_package=no

	# When:
	run assert_all_packages_are_installed com.example.Pkg.ID.1 com.example.Pkg.ID.7

	# Then:
	mocks_fetch_args
	[ "${args[0]}" == --pkg-info ]
	[ "${args[1]}" == com.example.Pkg.ID.1 ]
	[ "${args[2]}" == --pkg-info ]
	[ "${args[3]}" == com.example.Pkg.ID.7 ]

	[[ "${lines[0]}" =~ "'com.example.Pkg.ID.1' not installed.* Aborting." ]]
	[[ "${lines[1]}" =~ "'com.example.Pkg.ID.7' not installed.* Aborting." ]]
	[ "$status" -ne 0 ]
}

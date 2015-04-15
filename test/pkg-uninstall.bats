#!/usr/bin/env bats

load test-data
load test-helpers
load test-mocks

setup() {
	TMP_DIR=$(create_tmp functions.bash)
	cd "$TMP_DIR"
	cp "$BATS_TEST_DIRNAME/../src/pkg-uninstall" .

	old_PATH="$PATH"
	export PATH="$TMP_DIR:$PATH"
}

teardown() {
	export PATH="$old_PATH"

	rm_tmp "$TMP_DIR" functions.bash pkg-uninstall
}

assert_all_packages_are_installed_returns=0
assert_can_infer_prefix_dirs_if_necessary_returns=0
compute_prefix_directory_returns=0
validate_prefix_directory_returns=0
remove_files_and_dirs_returns=0
are_all_files_removed_returns=0
forget_package_returns=0
inject_mocks() {
	cat > "$TMP_DIR/functions.bash" <<EOF
# Mock
assert_all_packages_are_installed() {
	return $assert_all_packages_are_installed_returns
}

# Mock
assert_can_infer_prefix_dirs_if_necessary() {
	return $assert_can_infer_prefix_dirs_if_necessary_returns
}

# Mock
compute_prefix_directory() {
	return $compute_prefix_directory_returns
}

# Mock
validate_prefix_directory() {
	return $validate_prefix_directory_returns
}

# Mock
remove_files_and_dirs() {
	return $remove_files_and_dirs_returns
}

# Mock
are_all_files_removed() {
	return $are_all_files_removed_returns
}

# Mock
forget_package() {
	return $forget_package_returns
}
EOF
}


@test "should fail if any package is not already installed" {
	# Given
	assert_all_packages_are_installed_returns=1
	inject_mocks

	# When:
	run pkg-uninstall com.example.plop.Pkg.ID

	# Then:
	[ -z "$output" ]
	[ $status -eq 1 ]
}

@test "should fail if any prefix should be inferred but cannot" {
	# Given
	assert_can_infer_prefix_dirs_if_necessary_returns=1
	inject_mocks

	# When:
	run pkg-uninstall com.example.plop.Pkg.ID

	# Then:
	[ -z "$output" ]
	[ $status -eq 1 ]
}

@test "should fail on prefix computation, when uninstalling packages" {
	# Given
	compute_prefix_directory_returns=1
	inject_mocks

	# When:
	run pkg-uninstall com.example.plop.Pkg-1.ID com.example.plop.Pkg-2.ID

	# Then:
	echo_actual_output
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" == "--> Uninstalling package 'com.example.plop.Pkg-1.ID'" ]
	[ "${lines[1]}" == "--> Uninstalling package 'com.example.plop.Pkg-2.ID'" ]
	[ $status -eq 1 ]
}

@test "should fail on validating computed prefix, when uninstalling packages" {
	# Given
	validate_prefix_directory_returns=1
	inject_mocks

	# When:
	run pkg-uninstall com.example.plop.Pkg-1.ID com.example.plop.Pkg-2.ID

	# Then:
	echo_actual_output
	[ ${#lines[@]} -eq 4 ]
	[ $status -eq 1 ]
}

@test "should fail when all files are not removed after uninstalling packages" {
	# Given
	are_all_files_removed_returns=1
	inject_mocks

	# When:
	run pkg-uninstall com.example.plop.Pkg-1.ID com.example.plop.Pkg-2.ID

	# Then:
	echo_actual_output
	[ ${#lines[@]} -eq 6 ]
	[ $status -eq 1 ]
}

@test "should uninstall packages in order, ignoring any failures in removing files or packages" {
	# Given
	remove_files_and_dirs=1
	forget_package_returns=1
	inject_mocks

	# When:
	run pkg-uninstall com.example.plop.Pkg-1.ID com.example.plop.Pkg-2.ID

	# Then:
	[ ${#lines[@]} -eq 4 ]
	[ "${lines[0]}" == "--> Uninstalling package 'com.example.plop.Pkg-1.ID'" ]
	[ "${lines[2]}" == "--> Uninstalling package 'com.example.plop.Pkg-2.ID'" ]
	[ $status -eq 0 ]
}

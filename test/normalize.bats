#!/usr/bin/env bats

load ../src/functions

load test-data

@test "should not affect correct paths when normalizing" {
	result=$(echo -e "$FILES_WITH_BLANKS" \
					| normalize '>')
	[ "$result" == "$(echo -e "$FILES_WITH_BLANKS")" ]
}

@test "should contract multiple directory separators when normalizing" {
	result=$(echo -e "$FILES_WITH_MULTIPLE_DIR_SEPS" \
					| normalize '>')
#	echo expected: >&2
#	cat -t >&2 <<EOF
#$(echo -e "$FILES_WITH_BLANKS")
#EOF
#	echo actual: >&2
#	cat -t >&2 <<EOF
#$result
#EOF
	[ "$result" == "$(echo -e "$FILES_WITH_SINGLE_DIR_SEPS")" ]
}

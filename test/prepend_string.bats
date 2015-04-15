#!/usr/bin/env bats

load ../src/functions

load test-data

@test "should prepend string to each lines, supporting all sed reserved chars, and preserving blanks" {
	PFX='\//paf\\/ bim// [ /// * . ] poum]'
	result=$(echo -e "$FILES_WITH_BLANKS" \
					| prepend_string "$PFX")
#	echo expected: >&2
#	cat -t >&2 <<EOF
#${PFX}$(echo -e "${L2_F1}")
#${PFX}$(echo -e "${L2_F2}")
#${PFX}$(echo -e "${L2_F3}")
#EOF
#	echo actual: >&2
#	cat -t >&2 <<EOF
#$result
#EOF
	[ "$result" == "${PFX}$(echo -e "${L2_F1}")
${PFX}$(echo -e "${L2_F2}")
${PFX}$(echo -e "${L2_F3}")" ]
}

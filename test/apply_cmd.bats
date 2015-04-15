#!/usr/bin/env bats

load ../src/functions

load test-data

@test "should apply command on each lines, preserving blanks" {
	# When:
	dry_run=no
	run apply_cmd echo '>' <<EOF
$(echo -e "$FILES_WITH_BLANKS")
EOF

	# Then:
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" == "$(echo -e "> ${L2_F1}")" ]
	[ "${lines[1]}" == "$(echo -e "> ${L2_F2}")" ]
	[ "${lines[2]}" == "$(echo -e "> ${L2_F3}")" ]
	[ $status -eq 0 ]
}

@test "should explain what it would do when dry-run mode is enabled" {
	# When:
	dry_run=yes
	run apply_cmd echo '>' <<EOF
$(echo -e "$FILES_WITH_BLANKS")
EOF

	# Then:
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" == "$(echo -e "Would: echo > ${L2_F1}")" ]
	[ "${lines[1]}" == "$(echo -e "Would: echo > ${L2_F2}")" ]
	[ "${lines[2]}" == "$(echo -e "Would: echo > ${L2_F3}")" ]
	[ $status -eq 0 ]
}

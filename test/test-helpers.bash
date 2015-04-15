
# Create a set of files with dirs in a temporary directory
# Escape sequences in filenames like '\n' or '\t' are expanded
create_tmp() {
	local tmp_dir=$(mktemp -d -t "$(basename "$BATS_TEST_FILENAME")")
	cd "$tmp_dir"
	while [ -n "$1" ]; do
		local file=$(echo -e "$1")
		mkdir -p "$(dirname "$file")"
		touch "$file"
		shift
	done
	echo "$tmp_dir"
}

# Delete a set of temporarily created files
# Escape sequences in filenames like '\n' or '\t' are expanded
rm_tmp() {
	local tmp_dir="$1"
	shift

#	echo cd "$tmp_dir" # DEBUG
	cd "$tmp_dir"
#	find . -ls >&2 # DEBUG
	while [ -n "$1" ]; do
		local file=$(echo -e "$1")
#		echo rm "$file" >&2 # DEBUG
		rm "$file"
		local dir=$(dirname "$file")
		# safeguard rmdir '.' that would fail and have our test fail all together
		if [ "$dir" != . ]; then
#			echo rmdir -p "$dir" >&2 # DEBUG
			run_ignoring_status rmdir -p "$dir"
		fi
		shift
	done
#	echo rmdir "$tmp_dir" >&2 # DEBUG
	rmdir "$tmp_dir"
}

run_ignoring_status() {
  local e E T
  [[ "$-" =~ e ]] && e=1
  [[ "$-" =~ E ]] && E=1
  [[ "$-" =~ T ]] && T=1
  set +e
  set +E
  set +T
  "$@"
  [ -n "$e" ] && set -e
  [ -n "$E" ] && set -E
  [ -n "$T" ] && set -T
}

# Exact copy of the standard BATS run() function,
# but with STDERR muted to /dev/null,
# in order to run assertions on STDOUT only
run_with_muted_stderr() {
  local e E T oldIFS
  [[ ! "$-" =~ e ]] || e=1
  [[ ! "$-" =~ E ]] || E=1
  [[ ! "$-" =~ T ]] || T=1
  set +e
  set +E
  set +T
  output="$("$@" 2>/dev/null)"
  status=$?
  oldIFS="$IFS"
  IFS=$'\n' lines=($output)
  [ -z "$e" ] || set -e
  [ -z "$E" ] || set -E
  [ -z "$T" ] || set -T
  IFS="$oldIFS"
}

# Exact copy of the standard BATS run() function,
# but with STDOUT muted to /dev/null,
# in order to run assertions on STDERR only
run_with_muted_stdout() {
  local e E T oldIFS
  [[ ! "$-" =~ e ]] || e=1
  [[ ! "$-" =~ E ]] || E=1
  [[ ! "$-" =~ T ]] || T=1
  set +e
  set +E
  set +T
  output="$("$@" 2>&1 >/dev/null)"
  status=$?
  oldIFS="$IFS"
  IFS=$'\n' lines=($output)
  [ -z "$e" ] || set -e
  [ -z "$E" ] || set -E
  [ -z "$T" ] || set -T
  IFS="$oldIFS"
}

echo_actual_output() {
	echo actual output lines: ${#lines[@]} >&2
	echo actual output: >&2
	cat -t >&2 <<EOF
$output
EOF
}

echo_actual_mocks_output() {
	echo actual mocks output lines: ${#mocks_lines[@]} >&2
	echo actual mocks output: >&2
	cat -t "$MOCK_OUT" >&2
}

echo_actual_mocks_args() {
	echo actual mock args: >&2
	cat -t "$MOCK_ARGS" >&2
}

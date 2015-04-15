#!/bin/sh

# --------------------------------- #
# GENERAL PURPOSE UTILITY FUNCTIONS #
# --------------------------------- #

retain_dirs_with_min_path_elems() {
	local min_path_elems="$1"

	tr '\n' '\0' \
		| perl -0 -ne 'chomp; print "$_\n" if scalar(split(/\/+/, $_)) >= '"$min_path_elems"
}

shell_string_escape() {
	# Backslashes \ are escaped by backslashes \\
	sed -e 's/\\/\\\\/g'
}

sed_escape() {
	# Forward slashes / are escaped by backslashes \/
	# Dots . and stars * are escaped by backslashes: \. and \*
	# Square brackets [ and ] are escaped by backslashes \[ and \]
	shell_string_escape \
		| sed -e 's/\//\\\//g; s/\([.*]\)/\\\1/g; s/\[/\\[/g; s/\]/\\]/g'
}

prepend_string() {
	sed -e "s/^/`echo "$1" | sed_escape`/"
}

normalize() {
	sed -e 's/\/\{1,\}/\//g' # multiple repeated slashes are turned to into single slashes
}

reverse() {
	tail -r
}

apply_cmd() {
	if [ $dry_run = yes ]; then
		set echo Would: "$@"
	fi
	tr '\n' '\0' \
		| xargs -0 -n 1 "$@"
}

does_exist() {
	tr '\n' '\0' \
		| perl -0 -ne 'chomp; print((-e $_) ? "1\n" : "0\n")'
}

sum_and_count() {
	awk 'BEGIN{ S = 0; C = 0 } { S += $1; C += 1 } END{ print S "\t" C }'
}

retain_non_existing() {
	perl -ne 'chomp; print "$_\n" if ! -e'
}


# ------------------------- #
# DOMAIN SPECIFIC FUNCTIONS #
# ------------------------- #

assert_all_packages_are_installed() {
	local any_missing_package=no
	for pkg in "$@"; do
		if ! pkgutil --pkg-info "$pkg" > /dev/null 2>&1; then
			echo "$SELF: package '$pkg' is not installed. Please run 'pkgutil --pkgs' to review installed packages. Aborting." >&2
			any_missing_package=yes
		fi
	done
	if [ $any_missing_package = yes ]; then
		return 1
	else
		return 0
	fi
}

can_infer_prefix() {
	local pkg="$1"
	voters=`pkgutil --only-dirs --files "$pkg" \
		| retain_dirs_with_min_path_elems "$VOTERS_MIN_PATH_ELEMS" \
		| wc -l | awk '{print $1}'`
	if [ "$voters" -lt "$VOTERS_MIN_COUNT" ]; then
		echo "$SELF: WARN: too few voters" \
			 "(only $voters, needed $VOTERS_MIN_COUNT)" \
			 "to infer installation prefix directory for package '$pkg'." \
			 "Please specify a --prefix-dir argument. Aborting." >&2
		return 1
	fi
	return 0
}

assert_can_infer_prefix_dirs_if_necessary() {
	if [ $use_prefix_dir = yes ]; then
		return 0
	fi
	local can_infer=yes
	for pkg in "$@"; do
		if ! can_infer_prefix "$pkg"; then
			can_infer=no
		fi
	done
	if [ $can_infer = no ]; then
		return 1
	fi
	return 0
}

votes_for_prefix_candidates() {
	tr '\n' '\0' \
		| perl -0 -e '$dir_cnt = 0; %votes = ();
print STDERR "    Inferring installation prefix directory: ";
while ($dir = <>) {
	$dir_cnt += 1;
	chomp $dir;
	$dir = "/$dir";
#	print STDERR "dir: $dir\n"; # DEBUG
	@matches = split /\n/, `locate "$dir"`;
#	print STDERR "matches(".scalar(@matches)."):\n".(scalar(@matches) < 10 ? join("\n", @matches)."\n" : ""); # DEBUG
	@matching_pfxs = map {
			$pfx_len = length($_) - length($dir);
			if (index($_, $dir) == $pfx_len) {
				substr($_, 0, $pfx_len);
			} else {
				();
			}
		} @matches;
#	print STDERR "matching_pfxs:\n".join("\n", @matching_pfxs)."\n"; # DEBUG
	foreach $pfx (@matching_pfxs) {
		$votes{$pfx} += 1;
	}
	print STDERR ".";
}
print STDERR "\n";
# print STDERR "\nvoters: "; # DEBUG
# print STDERR "$dir_cnt\n"; # DEBUG
foreach $pfx (sort { $votes{$b} <=> $votes{$a} } keys %votes) {
	print $dir_cnt, "\t", $votes{$pfx}, "\t", $pfx, "\n";
}'
}

retain_single_unanimous_winner_only() {
	tr '\n' '\0' \
		| perl -0 -e '@winners = ();
while (<>) {
	chomp;
# print STDERR "line: $_\n";
	my ($quor, $votes, $pfx) = /^(\d+)\s+(\d+)\s+(.+)$/;
# print STDERR "quor: $quor, votes: $votes, pfx: $pfx\n";
	if ($quor < $votes) {
		exit 10;
	} elsif ($quor == $votes) {
		push @winners, $pfx;
	}
}
if (scalar(@winners) > 1) {
	exit 11;
} elsif (scalar(@winners) < 1) {
	exit 12;
}
print "$winners[0]\n";'
}

infer_prefix() {
	local pkg="$1"

	local voting_results=`pkgutil --only-dirs --files "$pkg" \
		| retain_dirs_with_min_path_elems "$VOTERS_MIN_PATH_ELEMS" \
		| votes_for_prefix_candidates`
	echo "$voting_results" | retain_single_unanimous_winner_only
	failure=$?
	if [ $failure -ne 0 ]; then
		if [ $failure -eq 10 ]; then
			echo "$SELF: internal ERROR, illegal result" \
				 "when voting for installation directory of package '$pkg'." >&2
		elif [ $failure -eq 11 ]; then
			echo "$SELF: too many matching installation directories for package '$pkg'." \
				 "Please specify one of these with --prefix-dir." >&2
		else
			echo "$SELF: cannot infer installation prefix directory for package '$pkg'." >&2
		fi
		if [ -n "$voting_results" ]; then
			echo "$SELF: Quorum, Votes, and Candidates were:" >&2
			echo "$voting_results" >&2
		fi
		return 1
	fi
	return 0
}

list() {
	local type="$1" # 'files', 'dirs', or anything else like 'dirs-and-files' for both
	# 2nd arg should be 'of:' for readability
	local pkg="$3"
	# 4th arg should be 'with:' for readability
	local pfx_dir="$5"

	restrict_arg=
	if [ "$type" = files -o "$type" = dirs ]; then
		restrict_arg="--only-${type}"
	fi
	pkgutil $restrict_arg --files "$pkg" \
		| prepend_string "${pfx_dir}/" | normalize
}

sum_and_count_existing() {
	local type="$1" # 'files', 'dirs', or 'dirs-and-files' for both
	# $2: 'of:'
	local pkg="$3"
	# $4: 'with:'
	local pfx_dir="$5"

	list "$type" of: "$pkg" with: "$pfx_dir" \
		| does_exist \
		| sum_and_count
}

list_non_existing() {
	local type="$1" # 'files', 'dirs', or 'dirs-and-files' for both
	# $2: 'of:'
	local pkg="$3"
	# $4: 'with:'
	local pfx_dir="$5"

	list "$type" of: "$pkg" with: "$pfx_dir" \
		| retain_non_existing
}

validate_existing() {
	local type="$1"
	# 2nd arg should be 'with:' for readability
	local existing_count="$3"
	# 4th arg should be 'out-of:' for readability
	local total_count="$5"

	non_existing_count=`expr "$total_count" - "$existing_count"`
	if [ "$non_existing_count" -gt 0 ]; then
		echo "$SELF: ERROR: $non_existing_count $type (out of $total_count in package '$pkg') cannot be found from prefix directory '$prefix'." \
			 "Please use --verbose to list them." \
			 "Please use --force to uninstall anyway. Aborting." >&2
		return 1
	fi
	return 0
}

compute_prefix_directory() {
	local pkg="$1"

	if [ $use_prefix_dir = yes ]; then
		echo "$prefix_dir"
	elif [ $do_infer_prefix_dir = yes ]; then
		infer_prefix "$pkg"
		# Propagate potential failure
		local failure=$?
		if [ $failure -ne 0 ]; then return $failure; fi
	else
		local volume=`pkgutil --pkg-info "$pkg" \
			| grep '^volume:' \
			| sed -e 's/^volume: //'`
		local pfx=`defaults read "/var/db/receipts/${pkg}.plist" InstallPrefixPath`
		echo "$volume/$pfx" | normalize
	fi
	return 0
}

validate_prefix_directory() {
	local pkg="$1"
	local pfx_dir="$2"

	local sum_and_count=`sum_and_count_existing dirs of: "$pkg" with: "$pfx_dir"`
	local existing_dirs_count=`echo "$sum_and_count" | cut -f 1`
	local total_dirs_count=`echo "$sum_and_count" | cut -f 2`
	echo "    Existing dirs: $existing_dirs_count / $total_dirs_count"
	sum_and_count=`sum_and_count_existing files of: "$pkg" with: "$pfx_dir"`
	local existing_files_count=`echo "$sum_and_count" | cut -f 1`
	local total_files_count=`echo "$sum_and_count" | cut -f 2`
	echo "    Existing files: $existing_files_count / $total_files_count"

	local missing_dirs=no
	if ! validate_existing dirs with: "$existing_dirs_count" out-of: "$total_dirs_count"; then
		missing_dirs=yes
		if [ $be_verbose = yes ]; then
			echo "Missing directories:" >&2
			list_non_existing dirs of: "$pkg" with: "$pfx_dir" >&2
		fi
	fi
	local missing_files=no
	if ! validate_existing files with: "$existing_files_count" out-of: "$total_files_count"; then
		missing_files=yes
		if [ $be_verbose = yes ]; then
			echo "Missing files:" >&2
			list_non_existing files of: "$pkg" with: "$pfx_dir" >&2
		fi
	fi
	if [ $missing_dirs = yes -o $missing_files = yes ]; then
		return 1
	fi
	return 0
}

remove_files_and_dirs() {
	local pkg="$1"
	local pfx_dir="$2"

	local out=
	if [ $dry_run = yes ]; then
		out=/dev/stdout
	else
		out=/dev/null
	fi
	list files of: "$pkg" with: "$pfx_dir" \
		| reverse \
		| apply_cmd rm > $out 2>&1
	list dirs of: "$pkg" with: "$pfx_dir" \
		| reverse \
		| apply_cmd rmdir > $out 2>&1
}

are_all_files_removed() {
	local pkg="$1"
	local pfx_dir="$2"

	list files of: "$pkg" with: "$pfx_dir" \
		| tr '\n' '\0' \
		| perl -0 -e '$err_status = 0;
while ($file = <>) {
	chomp $file;
	if (-e $file) {
		print STDERR "'"$SELF"': could not remove file '\''$file'\''. Skipped.\n";
		$err_status = 1;
	}
}
exit $err_status;'
	return $?
}

forget_package() {
	local pkg="$1"

	if [ $dry_run = yes ]; then
		echo Would: pkgutil --forget "$pkg"
	else
		pkgutil --forget "$pkg"
	fi
}

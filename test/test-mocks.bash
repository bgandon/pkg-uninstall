
# -------------------------------- #
# Helpers to create mock functions #
# -------------------------------- #

mocks_setup() {
    export MOCK_ARGS=$(mktemp -t "$(basename "$BATS_TEST_FILENAME")_$1-args")
    export MOCK_OUT=$(mktemp -t "$(basename "$BATS_TEST_FILENAME")_$1-out")
}

mocks_save_args() {
    if [ -z "$MOCK_ARGS" ]; then
        return 0
    fi
    for arg in "$@"; do
        echo "$arg" >> "$MOCK_ARGS"
    done
}

mocks_fetch_args() {
    if [ -z "$MOCK_ARGS" -o -z "$MOCK_OUT" ]; then
        return 1
    fi
    local oldIFS=$IFS
    IFS=$'\n' args=($(cat "$MOCK_ARGS"))
    IFS=$'\n' mocks_lines=($(cat "$MOCK_OUT"))
    IFS=$oldIFS
    mocks_cleanup
}

mocks_cleanup() {
    if [ -n "$MOCK_ARGS" -a -e "$MOCK_ARGS" ]; then
        rm "$MOCK_ARGS"
    fi
    export -n MOCK_ARGS=
    if [ -n "$MOCK_OUT" -a -e "$MOCK_OUT" ]; then
        rm "$MOCK_OUT"
    fi
    export -n MOCK_OUT=
}

# ------------------------------------------------ #
# Helpers to create mocked executables in the PATH #
# ------------------------------------------------ #

mocks_create_bin() {
    local tmp_dir="$1"
    local bin_name="$2"
    local src="$3"

    if [ ! -d bin ]; then
       mkdir bin
    fi
    cat "$src" > "bin/${bin_name}"
    chmod a+x "bin/${bin_name}"

    echo "$tmp_dir/bin"
}

mocks_cleanup_bin() {
    local old_PATH="$1"
    local bin_name="$2"

    export PATH="$old_PATH"

    rm "bin/${bin_name}"
    rmdir bin
}

# Local Variables:
# indent-tabs-mode: nil
# End:

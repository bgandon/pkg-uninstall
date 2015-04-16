
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

# Local Variables:
# indent-tabs-mode: nil
# End:

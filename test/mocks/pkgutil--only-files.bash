
# Mock
pkgutil_lists_files=without-blanks
pkgutil() {
    mocks_save_args "$@"
    if [ $pkgutil_lists_files = with-blanks ]; then
        echo -e "$FILES_WITH_BLANKS"
    else
        echo -e "$FILES_NO_SPACE"
    fi
}

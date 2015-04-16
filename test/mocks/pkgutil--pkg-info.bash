
# Mock
pkgutil_finds_package=yes
pkgutil() {
    mocks_save_args "$@"
    if [ $pkgutil_finds_package = yes ]; then
		echo volume: /plop-vol
        return 0
    else
        return 1
    fi
}

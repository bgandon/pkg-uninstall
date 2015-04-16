
# Mock
list_files=without-blanks
list() {
    mocks_save_args "$@"
    if [ $list_files = with-blanks ]; then
        echo -e "$5/$L2_F1"
        echo -e "$5/$L2_F2"
        echo -e "$5/$L2_F3"
    else
        echo -e "$5/$L1_F1"
        echo -e "$5/$L1_F2"
        echo -e "$5/$L1_F3"
    fi
}

# Local Variables:
# indent-tabs-mode: nil
# End:


# Mock
can_infer_prefix_answers=yes
can_infer_prefix() {
    mocks_save_args "$@"
    if [ $can_infer_prefix_answers = yes ]; then
        return 0
    else
        return 1
    fi
}

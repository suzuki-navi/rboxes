
show_help() {
    cat $script_dir/help.txt
}

user_args=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            show_help
            exit 0
            ;;
        -*)
            echo "Error: Unknown option $1" >&2
            show_help >&2
            exit 1
            ;;
        *)
            user_args+=("$1")
            shift
            ;;
    esac
done

set -- "${user_args[@]}"

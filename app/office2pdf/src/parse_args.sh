
show_help() {
    cat $script_dir/help.txt
}

# Parse command line options
if [[ $# -eq 0 ]]; then
    show_help
    exit 0
fi

source_file_path=""

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
            if [ -z "$source_file_path" ]; then
                source_file_path="$1"
                source_file_path=$(realpath "$source_file_path")
                user_args+=("$source_file_path")
            else
                echo "Error: Only one <PATH> argument is allowed." >&2
                show_help >&2
                exit 1
            fi
            shift
            ;;
    esac
done

source_dir_path=$(dirname "$source_file_path")

set -- "${user_args[@]}"

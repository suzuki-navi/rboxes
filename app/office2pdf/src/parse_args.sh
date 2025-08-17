
show_help() {
    cat $script_dir/help.txt
}

# Parse command line options
if [[ $# -eq 0 ]]; then
    show_help
    exit 0
fi

source_file_path=""
output_file_dir=""
output_file_path=""
force_overwrite=false

user_args=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            show_help
            exit 0
            ;;
        -o|--output)
            if [[ $# -lt 2 ]]; then
                echo "Error: Option $1 requires an argument" >&2
                show_help >&2
                exit 1
            fi
            output_file_path="$2"
            output_file_dir=$(dirname "$output_file_path")
            output_file_dir=$(cd "$output_file_dir" && pwd)
            output_file_path="$output_file_dir/$(basename "$output_file_path")"
            user_args+=("-o" "$output_file_path")
            shift 2
            ;;
        -f|--force)
            force_overwrite=true
            user_args+=("$1")
            shift
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
                echo "Error: Only one input file argument is allowed." >&2
                show_help >&2
                exit 1
            fi
            shift
            ;;
    esac
done

if [ -z "$source_file_path" ]; then
    echo "Error: No input file specified." >&2
    show_help >&2
    exit 1
fi

if [ -z "$output_file_path" ] || [ "$output_file_path" = "@" ]; then
    output_file_path="$source_file_path.pdf"
    output_file_dir=$(dirname "$output_file_path")
    output_file_dir=$(cd "$output_file_dir" && pwd)
    output_file_path="$output_file_dir/$(basename "$output_file_path")"
fi

set -- "${user_args[@]}"

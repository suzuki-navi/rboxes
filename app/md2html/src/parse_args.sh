#!/bin/bash

show_help() {
    cat "$script_dir/help.txt"
}

# Parse command line options
user_args=()
source_path=""
output_path=""
force=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            show_help
            exit 0
            ;;
        -o|--output-dir)
            if [[ -n "$2" && "$2" != -* ]]; then
                output_path="$2"
                output_path=$(realpath "$output_path")
                user_args+=("$1" "$output_path")
                shift 2
            else
                echo "Error: Option $1 requires an argument" >&2
                show_help >&2
                exit 1
            fi
            ;;
        -f|--force)
            force=true
            user_args+=("$1")
            shift
            ;;
        -*)
            echo "Error: Unknown option $1" >&2
            show_help >&2
            exit 1
            ;;
        *)
            if [[ -z "$source_path" ]]; then
                source_path="$1"
                source_path=$(realpath "$source_path")
                user_args+=("$source_path")
            else
                echo "Error: Only one <PATH> argument is allowed." >&2
                show_help >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# Check arguments
if [[ -z "$source_path" ]]; then
    echo "Error: Source path is required." >&2
    show_help >&2
    exit 1
fi

# Validate: if input is directory, output_path is required
if [[ -n "$source_path" && -d "$source_path" && -z "$output_path" ]]; then
    echo "Error: Output directory (-o) is required when input is a directory" >&2
    show_help >&2
    exit 1
fi

set -- "${user_args[@]}"

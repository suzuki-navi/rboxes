#!/bin/bash

show_help() {
    cat "$script_dir/help.txt"
}

# Parse command line options
target_path="."
use_compression=true

user_args=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            show_help
            exit 0
            ;;
        --no-compression)
            use_compression=false
            user_args+=("$1")
            shift
            ;;
        -*)
            echo "Error: Unknown option $1" >&2
            show_help >&2
            exit 1
            ;;
        *)
            if [ -z "$target_path" ] || [ "$target_path" = "." ]; then
                target_path="$1"
                target_path=$(realpath "$target_path")
                user_args+=("$target_path")
            else
                echo "Error: Only one PATH argument is allowed." >&2
                show_help >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate target path exists
if [ ! -e "$target_path" ]; then
    echo "Error: Path '$target_path' does not exist." >&2
    exit 1
fi

target_dir_path=$(dirname "$target_path")

set -- "${user_args[@]}"

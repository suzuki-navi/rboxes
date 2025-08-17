#!/bin/bash

show_help() {
    cat "$script_dir/help.txt"
}

# Parse command line options
user_args=()
output_dir=""
force_overwrite=false
output_specified=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_help
            exit 0
            ;;
        -d|--directory)
            if [[ -z "$2" ]]; then
                echo "Error: -d requires a directory path" >&2
                exit 1
            fi
            output_dir=$(realpath "$2")
            user_args+=("$1" "$output_dir")
            shift
            ;;
        -f|--force)
            force_overwrite=true
            user_args+=("$1")
            ;;
        -*)
            echo "Error: Unknown option $1" >&2
            show_help >&2
            exit 1
            ;;
        *)
            user_args+=("$1")
            ;;
    esac
    shift
done

# If no -d specified but we have arguments, treat as legacy format for backward compatibility
if [[ -z "$output_dir" ]]; then
    echo "Error: Must specify directory with -d" >&2
    exit 1
fi

set -- "${user_args[@]}"

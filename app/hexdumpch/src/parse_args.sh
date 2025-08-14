#!/bin/bash

show_help() {
    cat "$script_dir/help.txt"
}

# Parse command line options
user_args=()
width=16
input_file=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --help)
            show_help
            exit 0
            ;;
        -w|--width)
            if [[ -n $2 && $2 =~ ^[0-9]+$ ]]; then
                width=$2
                shift
            else
                echo "Error: --width requires a positive integer" >&2
                show_help >&2
                exit 1
            fi
            ;;
        -n|--no-break-on-newline)
            user_args+=("$1")
            ;;
        -*)
            echo "Error: Unknown option $1" >&2
            show_help >&2
            exit 1
            ;;
        *)
            if [[ -z "$input_file" ]]; then
                input_file="$1"
                input_file=$(realpath "$input_file")
                user_args+=("$input_file")
            else
                echo "Error: Too many arguments" >&2
                show_help >&2
                exit 1
            fi
            ;;
    esac
    shift
done

# Add width argument to user_args if not default
if [ "$width" != "16" ]; then
    if [[ -n "$input_file" ]]; then
        user_args=("-w" "$width" "$input_file")
    else
        user_args=("-w" "$width")
    fi
fi

set -- "${user_args[@]}"
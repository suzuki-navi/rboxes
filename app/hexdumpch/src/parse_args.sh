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
                user_args+=("$1" "$width")
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

set -- "${user_args[@]}"
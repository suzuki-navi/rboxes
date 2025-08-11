#!/bin/bash

show_help() {
    cat "$script_dir/help.txt"
}

# Parse command line options
user_args=()

while [[ $# -gt 0 ]]; do
    case $1 in
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
            ;;
    esac
    shift
done

# Check if project_key is provided
if [ ${#user_args[@]} -eq 0 ]; then
    echo "Error: project_key argument is required" >&2
    show_help >&2
    exit 1
fi

if [ ${#user_args[@]} -gt 1 ]; then
    echo "Error: Too many arguments" >&2
    show_help >&2
    exit 1
fi

# Check required environment variables
if [ -z "$BACKLOG_SPACE" ]; then
    echo "Error: BACKLOG_SPACE environment variable is required" >&2
    echo "Please set it to your Backlog space name (subdomain)" >&2
    exit 1
fi

if [ -z "$BACKLOG_API_KEY" ]; then
    echo "Error: BACKLOG_API_KEY environment variable is required" >&2
    echo "Please set it to your Backlog API key" >&2
    exit 1
fi


# Set default suffix if not provided
if [ -z "$BACKLOG_SUFFIX" ]; then
    export BACKLOG_SUFFIX="jp"
fi

# Validate suffix
if [ "$BACKLOG_SUFFIX" != "jp" ] && [ "$BACKLOG_SUFFIX" != "com" ]; then
    echo "Error: BACKLOG_SUFFIX must be 'jp' or 'com'" >&2
    exit 1
fi
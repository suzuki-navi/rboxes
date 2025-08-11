#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/load-env.sh"

source "$script_dir/parse_args.sh"

volumes=()
volumes+=("-v" "$pwd:$pwd")

bash "$script_dir/docker/write-env.sh" "$RXHOME/.rx.env" \
    BACKLOG_SPACE \
    BACKLOG_API_KEY \
    BACKLOG_PROJECT_KEY \
    BACKLOG_SUFFIX
    ;

bash "$script_dir/docker/entry2.sh" "${volumes[@]}" -- "${user_args[@]}"

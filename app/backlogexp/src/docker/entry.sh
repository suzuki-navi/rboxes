#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/load-env.sh"

source "$script_dir/parse_args.sh"

volumes=()
volumes+=("-v" "$pwd:$pwd")

envs=()
envs+=("-e" "BACKLOG_SPACE=${BACKLOG_SPACE:-}")
envs+=("-e" "BACKLOG_API_KEY=${BACKLOG_API_KEY:-}")
envs+=("-e" "BACKLOG_PROJECT_KEY=${BACKLOG_PROJECT_KEY:-}")
envs+=("-e" "BACKLOG_SUFFIX=${BACKLOG_SUFFIX:-jp}")

bash "$script_dir/docker/entry2.sh" "${volumes[@]}" "${envs[@]}" -- "${user_args[@]}"

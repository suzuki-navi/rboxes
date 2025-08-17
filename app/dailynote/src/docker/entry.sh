#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/load-env.sh"

source "$script_dir/parse_args.sh"

volumes=()

# Mount target directory if specified
if [[ -n "$output_dir" ]]; then
    volumes+=("-v" "$output_dir:$output_dir")
fi

bash "$script_dir/docker/entry2.sh" "${volumes[@]}" -- "${user_args[@]}"
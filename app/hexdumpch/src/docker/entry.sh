#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/load-env.sh"

source "$script_dir/parse_args.sh"

volumes=()

# If input file is specified, mount its directory
if [[ -n "$input_file" ]] && [[ -f "$input_file" ]]; then
    volumes+=("-v" "$input_file:$input_file")
fi

bash "$script_dir/docker/entry2.sh" "${volumes[@]}" -- "${user_args[@]}"
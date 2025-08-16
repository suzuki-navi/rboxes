#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/load-env.sh"

source "$script_dir/parse_args.sh"

volumes=()

if [[ -d "$source_path" ]]; then
    if [[ ! -e "$output_path" ]]; then
        mkdir -p "$output_path"
    fi
    volumes+=("-v" "$source_path:$source_path")
    volumes+=("-v" "$output_path:$output_path")
else
    src_dir=$(dirname "$source_path")
    out_dir=$(dirname "$output_path")
    volumes+=("-v" "$src_dir:$src_dir")
    if [[ "$out_dir" != "$src_dir" ]]; then
        volumes+=("-v" "$out_dir:$out_dir")
    fi
fi

bash "$script_dir/docker/entry2.sh" "${volumes[@]}" -- "${user_args[@]}"

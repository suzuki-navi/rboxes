
source "$(dirname "${BASH_SOURCE[0]}")/load-env.sh"

source "$script_dir/parse_args.sh"

volumes=()
volumes+=("-v" "$source_file_path":"$source_file_path")
volumes+=("-v" "$output_file_dir":"$output_file_dir")

if [ ! -d "$output_file_dir" ]; then
    mkdir -p "$output_file_dir"
fi

if [ $force_overwrite = false ] && [ -f "$output_file_path" ]; then
    echo "Error: Output file '$output_file_path' already exists. Use --force to overwrite." >&2
    exit 1
fi

bash "$script_dir/docker/entry2.sh" "${volumes[@]}" -- "${user_args[@]}"


set -euo pipefail

script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && cd .. && pwd)"
pwd="$(pwd)"

docker_args=()
user_args=()
found_double_dash=0

for arg in "$@"; do
    if [[ "$found_double_dash" -eq 0 && "$arg" == "--" ]]; then
        found_double_dash=1
        continue
    fi
    if [[ "$found_double_dash" -eq 0 ]]; then
        docker_args+=("$arg")
    else
        user_args+=("$arg")
    fi
done

set -- "${user_args[@]}"

calc_content_hash() {
    local files=()

    export LC_ALL=C.UTF-8

    for path in "$@"; do
        if [[ -d "$path" ]]; then
            while IFS= read -r -d '' file; do
                files+=("$file")
            done < <(find "$path" -type f -print0)
        elif [[ -f "$path" ]]; then
            files+=("$path")
        else
            echo "Cannot open file or directory $path" >&2
            return 1
        fi
    done

    if [[ ${#files[@]} -eq 0 ]]; then
        echo "No files to hash" >&2
        return 1
    fi

    # Sort files to ensure consistent hash
    sorted_files=($(printf '%s\n' "${files[@]}" | sort))
    sha256sum "${sorted_files[@]}" | sha256sum | awk '{print $1}'
}

docker_content_hash=$(
    cd "$script_dir"
    calc_content_hash *
)
docker_image_name="rx-${docker_content_hash}"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

if ! docker image inspect $docker_image_name >/dev/null 2>&1; then
    tmp_dockerfile="$tmp_dir/Dockerfile"
    (
        cat $script_dir/docker/Dockerfile
    ) > "$tmp_dockerfile"

    (
        cd $script_dir
        docker build . -f $tmp_dockerfile -t $docker_image_name
    )
fi

volumes=()
envs=()

#volumes+=("-v" "$script_dir:$script_dir")
#volumes+=("-v" "$pwd:$pwd")

io_opt=()
temp_file=""

if [ -t 1 ] && [ -t 0 ]; then
    io_opt+=("-it")
elif [ -t 1 ]; then
    temp_file="$tmp_dir/input"
    io_opt+=("-t")
elif [ -t 0 ]; then
    io_opt+=("-i")
else
    temp_file="$tmp_dir/input"
fi

if [[ -n "$temp_file" ]]; then
    volumes+=("-v" "$temp_file:$temp_file")
    cat > "$temp_file"
fi

uid=$(id -u)
gid=$(id -g)
user_opt=(--user "${uid}:${gid}")

if [ -n "${RX_VERBOSE:-}" ]; then
    envs+=("-e" "RX_VERBOSE=$RX_VERBOSE")
fi

if [ -n "${RX_VERBOSE:-}" ]; then
    echo docker run --rm "${io_opt[@]}" "${user_opt[@]}" \
        "${envs[@]}" \
        -e HOME="$HOME" \
        -e TZ="$TZ" \
        -w "$pwd" \
        "${volumes[@]}" \
        "${docker_args[@]}" \
        "$docker_image_name" "$temp_file" "$@"
fi

docker run --rm "${io_opt[@]}" "${user_opt[@]}" \
    "${envs[@]}" \
    -e HOME="$HOME" \
    -e TZ="$TZ" \
    -w "$pwd" \
    "${volumes[@]}" \
    "${docker_args[@]}" \
    "$docker_image_name" "$temp_file" "$@"

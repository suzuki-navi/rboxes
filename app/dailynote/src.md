## Dockerfile

```text Dockerfile
FROM ruby:3.4.4-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
        gosu \
        ;

COPY . /app
```

## main.sh

```bash main.sh
script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
pwd=$(pwd)

volumes=()

show_help() {
    cat $script_dir/help.txt
}

user_args=()
output_path=""
force_overwrite=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            show_help
            exit 0
            ;;
        -d|--directory)
            if [[ -z "$2" ]]; then
                echo "Error: -d requires a directory path" >&2
                show_help >&2
                exit 1
            fi
            output_path=$(realpath "$2")
            user_args+=("$1" "$output_path")
            shift 2
            ;;
        -f|--force)
            force_overwrite=true
            user_args+=("$1")
            shift
            ;;
        -*)
            echo "Error: Unknown option $1" >&2
            show_help >&2
            exit 1
            ;;
        *)
            user_args+=("$1")
            shift
            ;;
    esac
done

# If no -d specified but we have arguments, treat as legacy format for backward compatibility
if [[ -z "$output_path" ]]; then
    echo "Error: Must specify directory with -d" >&2
    show_help >&2
    exit 1
fi

volumes+=("-v" "$output_path:$output_path")

set -- "${user_args[@]}"

$script_dir/rdockrun "${volumes[@]}" $script_dir ruby /app/dailynote.rb "$@"
```


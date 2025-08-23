## Dockerfile
```text Dockerfile
FROM python:3.13.5-bookworm

COPY requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

COPY . /app
```

## requirements.txt
```text requirements.txt
BacklogPy
PyYAML
```

## main.sh
```bash main.sh
set -e

script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
pwd=$(pwd)

volumes=()

show_help() {
    cat $script_dir/help.txt
}

project_key=""
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
            shift 2
            ;;
        -f|--force)
            force_overwrite=true
            shift
            ;;
        -*)
            echo "Error: Unknown option $1" >&2
            show_help >&2
            exit 1
            ;;
        *)
            if [[ -n "$project_key" ]]; then
                echo "Error: Only one argument is allowed." >&2
                show_help >&2
                exit 1
            fi
            project_key="$1"
            shift
            ;;
    esac
done

if [[ -z "$output_path" ]]; then
    echo "Error: Output directory is not specified." >&2
    show_help >&2
    exit 1
fi

if ! $force_overwrite; then
    if [[ -e "$output_path" ]]; then
        if [[ -d "$output_path" ]] && [[ -z "$(ls -A "$output_path")" ]]; then
            : # Directory exists but is empty, allow
        else
            echo "Error: Output file $output_path already exists. Use -f to overwrite." >&2
            show_help >&2
            exit 1
        fi
    fi
fi

if [[ ! -e "$output_path" ]]; then
    mkdir -p "$output_path"
fi

volumes+=("-v" "$output_path:$output_path")

set -- "${user_args[@]}"

cd "$output_path"

RXHOME=$(mktemp -d)
trap 'rm -rf "$RXHOME"' EXIT
if [[ "$output_path" == "$HOME/"* ]]; then
    RXWORKDIR="$RXHOME/$(realpath --relative-to="$HOME" "$output_path")"
    mkdir -p "$RXWORKDIR"
fi
volumes+=("-v" "$RXHOME:$HOME")

source $script_dir/load-env.sh

bash $script_dir/write-env.sh "$RXHOME/.rx.env" \
    BACKLOG_SPACE \
    BACKLOG_API_KEY \
    BACKLOG_SUFFIX \
    ;

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

$script_dir/rdockrun "${volumes[@]}" $script_dir python /app/backlogexp.py "$project_key"
```

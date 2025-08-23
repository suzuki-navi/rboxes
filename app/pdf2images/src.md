## Dockerfile
```text Dockerfile
FROM python:3.13.5-bookworm

RUN apt update
RUN apt install -y poppler-utils

COPY requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

COPY . /app
```

## requirements.txt
```text requirements.txt
pdf2image
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

user_args=()
source_path=""
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
            if [[ -n "$source_path" ]]; then
                echo "Error: Only one <PATH> argument is allowed." >&2
                show_help >&2
                exit 1
            fi
            source_path=$(realpath "$1")
            user_args+=("$source_path")
            shift
            ;;
    esac
done

if [[ -z "$output_path" ]] || [[ "$output_path" == "@" ]]; then
    output_path="$source_path.pages"
fi

if ! $force_overwrite; then
    if [[ -e "$output_path" ]]; then
        echo "Error: Output file $output_path already exists. Use -f to overwrite." >&2
        show_help >&2
        exit 1
    fi
fi

if [[ ! -e "$output_path" ]]; then
    mkdir -p "$output_path"
fi

volumes+=("-v" "$source_path:$source_path")
volumes+=("-v" "$output_path:$output_path")

$script_dir/rdockrun "${volumes[@]}" $script_dir python /app/pdf2images.py "$source_path" "$output_path"
```

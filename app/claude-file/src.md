## Dockerfile

```text Dockerfile
FROM node:24-bookworm
RUN npm install -g @anthropic-ai/claude-code
COPY . /app
```

## main.sh

```bash main.sh
set -e

script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
pwd=$(pwd)

show_help() {
    cat $script_dir/help.txt
}

user_args=()
source_path=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            show_help
            exit 0
            ;;
        -*)
            if [[ -z "$source_path" ]]; then
                echo "Error: Unknown option $1" >&2
                exit 1
            fi
            user_args+=("$1")
            shift
            ;;
        *)
            if [[ -n "$source_path" ]]; then
                user_args+=("$1")
            else
                source_path=$(realpath "$1")
            fi
            shift
            ;;
    esac
done

if [[ -z "$source_path" ]]; then
    echo "Error: No source path specified." >&2
    exit 1
fi

source_dir=$(dirname "$source_path")



TMP_DIR=$(mktemp -d)
CLEANUP_DIRS=("$TMP_DIR")
CLEANUP_FILES=()
trap 'rm -rf "${CLEANUP_DIRS[@]}" "${CLEANUP_FILES[@]}"' EXIT
source $script_dir/claude-auth.sh

volumes=()
volumes+=("-v" "$source_path:$source_path")

if [[ -n "${CLAUDE_CODE_USER_HOME:-}" ]]; then
    RXHOME="$CLAUDE_CODE_USER_HOME"
else
    RXHOME="$pwd/var/.rx.home"
fi
mkdir -p "$RXHOME"
if [[ "$pwd" == "$HOME/"* ]]; then
    RXWORKDIR="$RXHOME/$(realpath --relative-to="$HOME" "$pwd")"
    mkdir -p "$RXWORKDIR"
    CLEANUP_DIRS+=("$RXWORKDIR")
fi
if [[ "$source_dir" == "$HOME/"* ]]; then
    DIR="$RXHOME/$(realpath --relative-to="$HOME" "$source_dir")"
    mkdir -p "$DIR"
    CLEANUP_DIRS+=("$DIR")
fi
if [[ -f "$source_path" ]]; then
    if [[ "$source_path" == "$HOME/"* ]]; then
        FILE="$RXHOME/$(realpath --relative-to="$HOME" "$source_path")"
        touch "$FILE"
        CLEANUP_FILES+=("$FILE")
    fi
elif [[ -d "$source_path" ]]; then
    if [[ "$source_path" == "$HOME/"* ]]; then
        DIR="$RXHOME/$(realpath --relative-to="$HOME" "$source_path")"
        mkdir -p "$DIR"
        CLEANUP_DIRS+=("$DIR")
    fi
fi
volumes+=("-v" "$RXHOME:$HOME")

set -- "${user_args[@]}"

cd $source_dir

$script_dir/rdockrun "${volumes[@]}" --envfile "$TMP_DIR/.rx.env" $script_dir claude "$@"
```

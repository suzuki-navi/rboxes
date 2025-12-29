## Dockerfile
```text Dockerfile
FROM debian:bookworm
RUN apt update
RUN apt install -y libreoffice
RUN apt install -y fonts-noto-cjk fonts-noto-cjk-extra locales

RUN apt install -y libipc-run3-perl
#RUN cpan -T IPC::Run3
RUN locale-gen ja_JP.UTF-8

COPY . /app
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
        -o|--output)
            if [[ -z "$2" ]]; then
                echo "Error: -o requires a file path" >&2
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

if [[ -z "$source_path" ]]; then
    echo "Error: No input file specified" >&2
    show_help >&2
    exit 1
fi

export LC_ALL=C.UTF-8

temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT

volumes+=("-v" "$temp_dir:$temp_dir")

ext="${source_path##*.}"

if [[ -z "$output_path" ]] || [[ "$output_path" == "@" ]]; then
    output_path="$source_path.pdf"
fi

if ! $force_overwrite; then
    if [[ -e "$output_path" ]]; then
        echo "Error: Output file $output_path already exists. Use -f to overwrite." >&2
        show_help >&2
        exit 1
    fi
fi

cp "$source_path" "$temp_dir/target.$ext"

$script_dir/rdockrun "${volumes[@]}" $script_dir perl /app/office2pdf.pl "$temp_dir/target.$ext"

if [[ ! -e "$temp_dir/target.pdf" ]]; then
    echo "Error: PDF file not created"
    exit 1
fi

cp "$temp_dir/target.pdf" "$output_path"
```

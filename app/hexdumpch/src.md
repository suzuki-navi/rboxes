## Dockerfile

```text Dockerfile
FROM ruby:3.4.4-bookworm
RUN gem install unicode-display_width
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
width=16
input_file=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            show_help
            exit 0
            ;;
        -w|--width)
            if [[ -n $2 && $2 =~ ^[0-9]+$ ]]; then
                width=$2
                user_args+=("$1" "$width")
                shift 2
            else
                echo "Error: --width requires a positive integer" >&2
                show_help >&2
                exit 1
            fi
            ;;
        -n|--no-break-on-newline)
            user_args+=("$1")
            shift
            ;;
        -*)
            echo "Error: Unknown option $1" >&2
            show_help >&2
            exit 1
            ;;
        *)
            if [[ -z "$input_file" ]]; then
                input_file="$1"
                input_file=$(realpath "$input_file")
                user_args+=("$input_file")
                shift
            else
                echo "Error: Too many arguments" >&2
                show_help >&2
                exit 1
            fi
            ;;
    esac
done

if [[ -n "$input_file" ]] && [[ -f "$input_file" ]]; then
    volumes+=("-v" "$input_file:$input_file")
fi

set -- "${user_args[@]}"

$script_dir/rdockrun "${volumes[@]}" $script_dir ruby /app/hexdumpch.rb "$@"
```

## Dockerfile

```text Dockerfile
FROM ruby:3.4.4-bookworm
RUN gem install specific_install
RUN gem specific_install -l https://github.com/suzuki-navi/suzuki-navi-calendar.git
```

## main.sh

```bash main.sh
script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

show_help() {
    cat $script_dir/help.txt
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            show_help
            exit 0
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

set -- "${user_args[@]}"

$script_dir/rdockrun $script_dir cal "$@"
```


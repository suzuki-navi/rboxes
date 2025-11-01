## Dockerfile

```text Dockerfile
FROM golang:1.25-bookworm
RUN apt update
RUN apt install -y fonts-liberation
RUN go install github.com/awslabs/diagram-as-code/cmd/awsdac@latest
```

フォントがないと以下のエラーになる
`panic: Specified fonts are not inllstalled.`

## main.sh

```bash main.sh
set -e

script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
pwd=$(pwd)

volumes=()
volumes+=("-v" "$pwd:$pwd")

show_help() {
    echo "Usage:"
    echo "  awsdac <input filename> [flags]"
    echo ""
    echo "Flags:"
    echo "  -c, --cfn-template               [beta] Create diagram from CloudFormation template"
    echo "  -d, --dac-file                   [beta] Generate YAML file in dac (diagram-as-code) format from CloudFormation template"
    echo "  -h, --help                       help for awsdac"
    echo "  -o, --output string              Output file name (default \"output.png\")"
    echo "      --override-def-file string   For testing purpose, override DefinitionFiles to another url/local file"
    echo "  -t, --template                   Processes the input file as a template according to text/template."
    echo "  -v, --verbose                    Enable verbose logging"
    echo "      --version                    version for awsdac"
}

user_args=()
input_file=""
output_file=""
cfn_template=false
dac_file=false
template_mode=false
verbose=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        --version)
            user_args+=("$1")
            shift
            ;;
        -c|--cfn-template)
            cfn_template=true
            user_args+=("$1")
            shift
            ;;
        -d|--dac-file)
            dac_file=true
            user_args+=("$1")
            shift
            ;;
        -o|--output)
            if [[ -z "$2" ]]; then
                echo "Error: -o requires a file path" >&2
                show_help >&2
                exit 1
            fi
            output_file=$(realpath "$2")
            user_args+=("$1" "$output_file")
            shift 2
            ;;
        -t|--template)
            template_mode=true
            user_args+=("$1")
            shift
            ;;
        -v|--verbose)
            verbose=true
            user_args+=("$1")
            shift
            ;;
        -*)
            echo "Error: Unknown option $1" >&2
            show_help >&2
            exit 1
            ;;
        *)
            if [[ -n "$input_file" ]]; then
                echo "Error: Only one input filename is allowed." >&2
                show_help >&2
                exit 1
            fi
            if [[ ! -f "$1" ]]; then
                echo "Error: Input file '$1' does not exist." >&2
                exit 1
            fi
            input_file=$(realpath "$1")
            user_args+=("$input_file")
            shift
            ;;
    esac
done

# Check if input file is provided (unless --version or --help was used)
if [[ -z "$input_file" && ! "${user_args[*]}" =~ "--version" ]]; then
    echo "Error: Input filename is required." >&2
    show_help >&2
    exit 1
fi

temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT

volumes+=("-v" "$temp_dir:$HOME/.cache")

if [[ ! -f "$input_file" ]]; then
    echo "Error: Input file '$input_file' does not exist." >&2
    exit 1
fi
volumes+=("-v" "$input_file:$input_file")
if [[ -z "$output_file" ]]; then
    volumes+=("-v" "$pwd:$pwd")
else
    output_dir=$(dirname "$output_file")
    volumes+=("-v" "$output_dir:$output_dir")
fi

$script_dir/rdockrun "${volumes[@]}" $script_dir awsdac "${user_args[@]}"
```

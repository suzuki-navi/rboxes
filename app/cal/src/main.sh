
script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

source "$script_dir/parse_args.sh"

cal "$@"

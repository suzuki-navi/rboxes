
source "$(dirname "${BASH_SOURCE[0]}")/load-env.sh"

source "$script_dir/parse_args.sh"

bash "$script_dir/docker/entry2.sh" -- "$@"

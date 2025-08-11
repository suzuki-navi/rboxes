
source "$(dirname "${BASH_SOURCE[0]}")/load-env.sh"

bash "$script_dir/docker/entry2.sh" -- "$@"

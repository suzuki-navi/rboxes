
script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && cd .. && pwd)"
pwd="$(pwd)"
is_debug=0
if [ -n "${RX_VERBOSE:-}" ]; then
    is_debug=1
fi

# Collect all parent directories from root to $pwd
dirs=()
parent_dir="$pwd"
while [ "$parent_dir" != "/" ]; do
    dirs=("$parent_dir" "${dirs[@]}")
    parent_dir="$(dirname "$parent_dir")"
done
parent_dir="$script_dir"
while [ "$parent_dir" != "/" ]; do
    dirs=("$parent_dir" "${dirs[@]}")
    parent_dir="$(dirname "$parent_dir")"
done
# Source .rx.env from parent to $pwd in order
set -a
for dir in "${dirs[@]}"; do
    if [ -f "$dir/.rx.env" ]; then
        source "$dir/.rx.env"
        if [ $is_debug -eq 1 ]; then
            echo "Sourced $dir/.rx.env"
        fi
        #break
    else
        if [ $is_debug -eq 1 ]; then
            echo "Not found $dir/.rx.env"
        fi
    fi
done
set +a

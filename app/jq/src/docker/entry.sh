
script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && cd .. && pwd)"
pwd=$(pwd)

volumes=()
volumes+=("-v" "$pwd:$pwd")

bash "$script_dir/docker/entry2.sh" "${volumes[@]}" -- "$@"

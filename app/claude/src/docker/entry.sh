
source "$(dirname "${BASH_SOURCE[0]}")/load-env.sh"

RXHOME="$pwd/var/rx.home"
mkdir -p "$RXHOME"

if [[ "$pwd" == "$HOME/"* ]]; then
    RXWORKDIR="$RXHOME/$(realpath --relative-to="$HOME" "$pwd")"
    mkdir -p "$RXWORKDIR"
fi

volumes=()
volumes+=("-v" "$pwd:$pwd")
volumes+=("-v" "$RXHOME:$HOME")

envs=()
envs+=("-e" "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-}")
envs+=("-e" "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-}")
envs+=("-e" "AWS_REGION=${AWS_REGION:-}")
envs+=("-e" "CLAUDE_CODE_USE_BEDROCK=${CLAUDE_CODE_USE_BEDROCK:-}")
envs+=("-e" "ANTHROPIC_MODEL=${ANTHROPIC_MODEL:-}")

bash "$script_dir/docker/entry2.sh" "${volumes[@]}" "${envs[@]}" -- "$@"

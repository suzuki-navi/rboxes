
source "$(dirname "${BASH_SOURCE[0]}")/load-env.sh"

mkdir -p "$pwd/.claude/.rx.home"

volumes=()
volumes+=("-v" "$pwd:$pwd")
volumes+=("-v" "$pwd/.claude/.rx.home:$HOME")

envs=()
envs+=("-e" "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-}")
envs+=("-e" "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-}")
envs+=("-e" "AWS_REGION=${AWS_REGION:-}")
envs+=("-e" "CLAUDE_CODE_USE_BEDROCK=${CLAUDE_CODE_USE_BEDROCK:-}")
envs+=("-e" "ANTHROPIC_MODEL=${ANTHROPIC_MODEL:-}")

bash "$script_dir/docker/entry2.sh" "${volumes[@]}" "${envs[@]}" -- "$@"

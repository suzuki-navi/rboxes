
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

bash $script_dir/docker/write-env.sh "$RXHOME/.rx.env" \
    AWS_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY \
    AWS_REGION \
    CLAUDE_CODE_USE_BEDROCK \
    ANTHROPIC_MODEL \
    ;

bash "$script_dir/docker/entry2.sh" "${volumes[@]}" -- "$@"

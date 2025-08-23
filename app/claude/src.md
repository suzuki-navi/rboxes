## Dockerfile

```text Dockerfile
FROM node:24-bookworm
RUN npm install -g @anthropic-ai/claude-code
COPY . /app
```

## main.sh

```bash main.sh
script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
pwd=$(pwd)

volumes=()
volumes+=("-v" "$pwd:$pwd")

RXHOME="$pwd/var/rx.home"
mkdir -p "$RXHOME"
if [[ "$pwd" == "$HOME/"* ]]; then
    RXWORKDIR="$RXHOME/$(realpath --relative-to="$HOME" "$pwd")"
    mkdir -p "$RXWORKDIR"
fi
volumes+=("-v" "$RXHOME:$HOME")

source $script_dir/load-env.sh

bash $script_dir/write-env.sh "$RXHOME/.rx.env" \
    AWS_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY \
    AWS_REGION \
    CLAUDE_CODE_USE_BEDROCK \
    ANTHROPIC_MODEL \
    ;

$script_dir/rdockrun "${volumes[@]}" $script_dir claude "$@"
```

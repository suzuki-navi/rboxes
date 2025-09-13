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

TMP_DIR=$(mktemp -d)
CLEANUP_DIRS=("$TMP_DIR")
trap 'rm -rf "${CLEANUP_DIRS[@]}"' EXIT
source $script_dir/claude-auth.sh

volumes=()
volumes+=("-v" "$pwd:$pwd")

if [[ -n "${CLAUDE_CODE_USER_HOME:-}" ]]; then
    RXHOME="$CLAUDE_CODE_USER_HOME"
else
    RXHOME="$pwd/var/.rx.home"
fi
mkdir -p "$RXHOME"
if [[ "$pwd" == "$HOME/"* ]]; then
    RXWORKDIR="$RXHOME/$(realpath --relative-to="$HOME" "$pwd")"
    mkdir -p "$RXWORKDIR"
    CLEANUP_DIRS+=("$RXWORKDIR")
fi
volumes+=("-v" "$RXHOME:$HOME")

mkdir -p "$RXHOME/.claude/commands"
for f in "$script_dir/"*.md; do
    cp "$f" "$RXHOME/.claude/commands/"
done

$script_dir/rdockrun "${volumes[@]}" --envfile "$TMP_DIR/.rx.env" $script_dir claude "$@"
```

## claude-auth.sh

```sh claude-auth.sh
source $script_dir/load-env.sh
if [[ "${CLAUDE_CODE_USE_BEDROCK:-}" == "1" ]]; then
    bash $script_dir/write-env.sh "$TMP_DIR/.rx.env" \
        AWS_ACCESS_KEY_ID \
        AWS_SECRET_ACCESS_KEY \
        AWS_REGION \
        AWS_BEARER_TOKEN_BEDROCK \
        CLAUDE_CODE_USE_BEDROCK \
        ANTHROPIC_MODEL \
        ;
fi
```

## chat.md

```markdown chat.md
The following chat file contains recorded conversations between an AI and users. Please write the AI's response that continues this conversation.
Chat file: $ARGUMENTS

Please also record the AI's response in the above file and save it as part of the conversation history.
```

## suggest-commit-message.md

```markdown suggest-commit-message.md
Check the staged changes in Git and come up with a commit message.
```

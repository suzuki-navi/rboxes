## Dockerfile

```text Dockerfile
FROM node:24-bookworm
RUN apt-get update && apt-get install -y docker.io
RUN npm install -g @anthropic-ai/claude-code@2.0.50
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

rm -rf "$RXHOME/.claude/commands"
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
Chat file: `$ARGUMENTS`

Please also record the AI's response in the above file and save it as part of the conversation history.
```

## git-commit.md

```markdown git-commit.md
Check the staged changes in Git, come up with a commit message, and execute the git commit command with that message.

IMPORTANT: Only execute the `git commit` command. Do NOT execute `git add` or any other git commands that modify the staging area.

IMPORTANT: Do NOT include any Claude attribution messages such as "Generated with Claude" or "Co-Authored-By: Claude" in the commit message.
```

## git-diff.md

```markdown git-diff.md
Analyze the Git commits in the specified range and summarize the development activities.

Commit range: `$ARGUMENTS`

Please perform the following analysis:

1. Execute `git log` for the specified commit range to retrieve:
   - Commit messages
   - Authors
   - Commit dates
   - Commit hashes

2. Execute `git diff` for the specified range to examine the actual code changes

3. Provide a comprehensive summary including:
   - Overview of what was changed
   - Key features or fixes implemented
   - Files and components affected
   - Summary of each developer's contributions

IMPORTANT: Keep the activity summary concise - approximately 5 lines or less per major topic.

Note: The commit range can be specified in various formats:
- Commit hash range: `c1e92fa..e120009`
- Relative to HEAD: `HEAD~3..HEAD`
- Single commit: `HEAD` (will analyze HEAD compared to its parent)

If only a single commit hash or HEAD is provided, analyze that commit compared to its parent commit.
```

## rename.md

```markdown rename.md
Please rename the file `$ARGUMENTS` to an appropriate filename based on its content. Analyze the file content and suggest a descriptive and meaningful filename that reflects what the file contains or its purpose.

Also examine other files in the same directory and workspace to understand the existing naming conventions and patterns. Consider factors such as:
- File naming patterns used by similar files in the project
- Consistent use of separators (dashes, underscores, etc.)
- Naming style (camelCase, snake_case, kebab-case, etc.)
- Common prefixes or suffixes used in the project

After deciding on the new filename that follows the project's naming conventions, please perform the actual file rename operation.
```


set -e

script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
pwd=$(pwd)

CONFIG_MD_FILE_NAME="rrun.md"
PROFILE_MD_FILE_NAME="rrun.profile.md"

# Find the config markdown file in current or parent directories
config_md_file_path=""
profile_md_file_path=""
current_dir="$pwd"
while [ "$current_dir" != "/" ]; do
    if [ -f "$current_dir/$CONFIG_MD_FILE_NAME" ]; then
        config_md_file_path="$current_dir/$CONFIG_MD_FILE_NAME"
        break
    fi
    current_dir=$(dirname "$current_dir")
done

if [ -z "$config_md_file_path" ]; then
    echo "Error: $CONFIG_MD_FILE_NAME not found in current or parent directories." >&2
    exit 1
fi

if [ -f "$(dirname "$config_md_file_path")/$PROFILE_MD_FILE_NAME" ]; then
    profile_md_file_path="$(dirname "$config_md_file_path")/$PROFILE_MD_FILE_NAME"
fi

mount_home_dir_path="$(dirname "$config_md_file_path")/.rrun.home"
mkdir -p "$mount_home_dir_path"

mkdir -p "$HOME/.rrun/cache"
tmpctx="$(mktemp -d $HOME/.rrun/cache/XXXXXX)"
cleanup() { rm -rf "$tmpctx"; }
trap cleanup EXIT

$script_dir/extractmarkdown -d "$tmpctx" "$config_md_file_path"

if [ -n "$profile_md_file_path" ]; then
    $script_dir/extractmarkdown --force -d "$tmpctx" "$profile_md_file_path"
fi

RDOCKRUN_OPTIONS="--pwd -v $tmpctx:$tmpctx -v $mount_home_dir_path:$HOME"

if [ -f "$tmpctx/RDOCKRUN_ENV" ]; then
    RDOCKRUN_OPTIONS="$RDOCKRUN_OPTIONS --envfile $tmpctx/RDOCKRUN_ENV"

    additional_options=$(
        RDOCKRUN_OPTIONS=""
        . "$tmpctx/RDOCKRUN_ENV"
        echo "$RDOCKRUN_OPTIONS"
    )
    RDOCKRUN_OPTIONS="$RDOCKRUN_OPTIONS $additional_options"
fi

$script_dir/rdockrun $RDOCKRUN_OPTIONS "$tmpctx" "$@"

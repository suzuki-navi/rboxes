
script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

source "$script_dir/parse_args.sh"

temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT

ext="${source_file_path##*.}"

source_file_path2="$temp_dir/target.$ext"

cp "$source_file_path" "$source_file_path2"

python "$script_dir/pdf2images.py" "$source_file_path2"

mkdir -p "$source_file_path.pages"
cp -r "$source_file_path2.pages/"* "$source_file_path.pages/"

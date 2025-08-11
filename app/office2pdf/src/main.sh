
#export LC_ALL=ja_JP.UTF-8
export LC_ALL=C.UTF-8
#export LANG=ja_JP.UTF-8

script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

source "$script_dir/parse_args.sh"

temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT

ext="${source_file_path##*.}"

source_file_path2="$temp_dir/target.$ext"

cp "$source_file_path" "$source_file_path2"

python "$script_dir/office2pdf.py" "$source_file_path2"

pdf_file_path2="${source_file_path2%.*}.pdf"
pdf_file_path="${source_file_path}.pdf"

if [ -f "$pdf_file_path2" ]; then
    cp "$pdf_file_path2" "$pdf_file_path"
fi

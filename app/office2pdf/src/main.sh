
#export LC_ALL=ja_JP.UTF-8
export LC_ALL=C.UTF-8
#export LANG=ja_JP.UTF-8

script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

source "$script_dir/parse_args.sh"

temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT

ext="${source_file_path##*.}"

source_file_path2="$temp_dir/target.$ext"
temp_pdf_path="$temp_dir/target.pdf"

cp "$source_file_path" "$source_file_path2"

perl "$script_dir/office2pdf.pl" "$source_file_path2" "$temp_pdf_path"

if [ ! -f "$temp_pdf_path" ]; then
    echo "Error: PDF conversion failed" >&2
    exit 1
fi

cp "$temp_pdf_path" "$output_file_path"

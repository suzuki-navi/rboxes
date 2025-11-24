
# Bash wrapper generator for rsealpack
# Generates a Bash script that embeds the binary and executes it

set -e

if [ $# -ne 3 ]; then
    echo "Usage: $0 <binary_path> <output_path> <hash>" >&2
    exit 1
fi

binary_path="$1"
output_path="$2"
hash="$3"

if [ ! -f "$binary_path" ]; then
    echo "Error: Binary file not found: $binary_path" >&2
    exit 1
fi

# バイナリを圧縮してからBase64エンコード（76文字ごとに改行）
binary_b64=$(gzip -c "$binary_path" | base64 -w 76)

# Bashスクリプトを生成
cat > "$output_path" << EOF
##:$hash
EOF

cat >> "$output_path" << 'EOF'
# rsealpack generated script
set -e

binary_data="$(cat << 'BINARY_EOF'
EOF

# バイナリデータを出力
echo "$binary_b64" >> "$output_path"

# スクリプトの残り部分を出力
cat >> "$output_path" << 'EOF'
BINARY_EOF
)"

cleanup() {
    if [ -n "$temp_dir" ] && [ -d "$temp_dir" ]; then
        rm -rf "$temp_dir"
    fi
}
trap cleanup EXIT INT TERM
temp_dir=$(mktemp -d)
tmpbin_path="$temp_dir/rsealpack.bin"
echo "$binary_data" | base64 -d | gunzip > "$tmpbin_path"
chmod +x "$tmpbin_path"
exec "$tmpbin_path" "$@"
EOF

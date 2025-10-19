#!/bin/bash

# Bash wrapper generator for rsealpack
# Generates a Bash script that embeds the binary and executes it

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <binary_path> <output_path>" >&2
    exit 1
fi

binary_path="$1"
output_path="$2"

if [ ! -f "$binary_path" ]; then
    echo "Error: Binary file not found: $binary_path" >&2
    exit 1
fi

# バイナリを圧縮してからBase64エンコード（76文字ごとに改行）
binary_b64=$(gzip -c "$binary_path" | base64 -w 76)

# Bashスクリプトを生成
cat > "$output_path" << 'EOF'
#!/bin/bash

# 自動生成されたBashラッパー - rsealpackバイナリが埋め込まれています
set -e

# 埋め込まれたバイナリ (gzip圧縮 + Base64エンコード済み)
binary_data="$(cat << 'BINARY_EOF'
EOF

# バイナリデータを出力
echo "$binary_b64" >> "$output_path"

# スクリプトの残り部分を出力
cat >> "$output_path" << 'EOF'
BINARY_EOF
)"

# クリーンアップ用のtrapを設定
cleanup() {
    if [ -n "$temp_dir" ] && [ -d "$temp_dir" ]; then
        rm -rf "$temp_dir"
    fi
}
trap cleanup EXIT INT TERM

# 一時ディレクトリを作成
temp_dir=$(mktemp -d)
tmpbin_path="$temp_dir/rsealpack.bin"

# データ復元プロセス
# Step 1-3: Base64デコード → gzip展開 → 実行可能バイナリ復元
echo "$binary_data" | base64 -d | gunzip > "$tmpbin_path"

# 実行権限を付与
chmod +x "$tmpbin_path"

# 元のコマンドライン引数をそのまま渡して実行
exec "$tmpbin_path" "$@"
EOF


add_gitignore() {
    local file=".gitignore"

    # .gitignore が存在しなければ作成
    [ -f "$file" ] || touch "$file"

    # 各パラメータに対して処理
    for pattern in "$@"; do
        # 既に同じ行があれば次へ
        if grep -Fxq "$pattern" "$file"; then
            continue
        fi

        # 最後に改行がなければ追加
        if [ -s "$file" ] && [ "$(tail -c1 "$file" | wc -l)" -eq 0 ]; then
            printf '\n' >> "$file"
        fi

        echo "$pattern" >> "$file"
        echo "Added to $file: $pattern"
    done
}

smart_cp() {
    local src="$1"
    local dst="$2"

    # コピー元が存在しない場合
    if [ ! -f "$src" ]; then
        echo "Source file not found: $src" >&2
        return 1
    fi

    # コピー先が存在する場合は内容比較
    if [ -f "$dst" ]; then
        if cmp -s "$src" "$dst"; then
            return 0
        fi
    fi

    dstdir="$(dirname "$dst")"
    mkdir -p "$dstdir"

    cp "$src" "$dst"
    echo "Copied $src to $dst"
}

smart_mv() {
    local src="$1"
    local dst="$2"

    # コピー元が存在しない場合
    if [ ! -f "$src" ]; then
        echo "Source file not found: $src" >&2
        return 1
    fi

    # コピー先が存在する場合は内容比較
    if [ -f "$dst" ]; then
        if cmp -s "$src" "$dst"; then
            rm -f "$src"
            return 0
        fi
    fi

    dstdir="$(dirname "$dst")"
    mkdir -p "$dstdir"

    mv -f "$src" "$dst"
    echo "Updated $dst"
}

build_app() {
    local srcdir="$1"
    local dstdir="${2:-}"

    local appname
    appname="$(basename "$srcdir")"

    # ハッシュ計算用のディレクトリを準備
    local hash_dir="$srcdir/../../lib/build-hash"
    mkdir -p "$hash_dir"

    local hash_file="$hash_dir/$appname.txt"

    # アプリディレクトリ内のgit管理ファイルのハッシュを計算
    local current_hash
    if [ -d "$srcdir/.git" ] || git rev-parse --git-dir > /dev/null 2>&1; then
        current_hash=$(cd "$srcdir" && git ls-files | LANG=C sort | xargs -r sha256sum 2>/dev/null | sha256sum | awk '{print $1}')
    else
        echo "Warning: Not a git repository, building without hash check" >&2
        current_hash=""
    fi

    # 前回のハッシュ値を読み込み
    local previous_hash=""
    if [ -f "$hash_file" ]; then
        previous_hash=$(cat "$hash_file")
    fi

    # ハッシュが一致する場合はビルドをスキップ
    if [ -n "$current_hash" ] && [ "$current_hash" = "$previous_hash" ] && [ -f "$srcdir/$appname" ]; then
        echo "Skipping build for $appname (no changes detected)"
    else
        # ビルド実行
        if [ -f "$srcdir/build.sh" ]; then
            echo "Building $appname..."
            (cd "$srcdir" && bash "./build.sh") || {
                echo "Build failed" >&2
                return 1
            }
        else
            echo "No build.sh found in $srcdir, skipping build" >&2
        fi
    fi

    # ビルド成功時にハッシュを保存
    if [ -n "$current_hash" ]; then
        echo "$current_hash" > "$hash_file"
    fi

    if [ -n "$dstdir" ]; then
        mkdir -p "$dstdir"
        smart_cp "$srcdir/$appname" "$dstdir/$appname"
    fi
}

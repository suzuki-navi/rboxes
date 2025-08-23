
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
    local dstdir="$2"

    local appname
    appname="$(basename "$srcdir")"

    if [ -f "$srcdir/build.sh" ]; then
        (cd "$srcdir" && bash "./build.sh") || {
            echo "Build failed" >&2
            return 1
        }
    fi

    mkdir -p "$dstdir"
    smart_cp "$srcdir/$appname" "$dstdir/$appname"
}

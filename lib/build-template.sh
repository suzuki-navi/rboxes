#!/bin/bash

set -euo pipefail

app_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
cd $app_dir

dst="__APP_NAME__"
main_script="docker/entry.sh"
cp ../../lib/entry2.sh src/docker/
cp ../../lib/entry3.sh src/docker/

calc_file_content_hash() {
    local file="$1"
    sha256sum "$file" | awk '{print $1}' | cut -b-8
}

is_binary_file() {
    file="$1"

    # 1. Check if file contains control characters (0x00-0x1F) except newline (0x0A)
    if LC_ALL=C grep -qP '[\x00-\x09\x0B-\x1F]' "$file"; then
        return 0  # Treat as binary
    fi

    # 2. Check if file doesn't end with newline
    if [ -s "$file" ]; then
        last_char=$(tail -c1 "$file")
        if [ "$last_char" != "" ] && [ "$last_char" != $'\n' ]; then
            return 0  # Treat as binary
        fi
    fi

    return 1  # Treat as text
}

make_self_extract_script() {
    find . -type f | LC_ALL=C sort | while read -r file_path; do
        file_path="${file_path#./}"

        if [ "$(dirname "$file_path")" != "." ]; then
            printf 'mkdir -p "%s"\n' "$(dirname "$file_path")"
        fi

        file_hash=$(calc_file_content_hash "$file_path")
        if [ ! -s "$file_path" ]; then
            # Empty file - create empty file
            printf 'echo "" > "%s"\n' "$file_path"
        elif is_binary_file "$file_path"; then
            # Binary file - encode with base64 and output
            printf 'base64 -d > "%s" << END_OF_%s\n' "$file_path" $file_hash
            base64 "$file_path"
            echo "END_OF_$file_hash"
        else
            # Text file - output as plain text
            printf 'cat > "%s" << '\''END_OF_%s'\''\n' "$file_path" $file_hash
            cat "$file_path"
            echo "END_OF_$file_hash"
        fi
        echo
    done | (
        temp_file=$(mktemp)
        cat > "$temp_file"
        file_hash=$(calc_file_content_hash "$temp_file")
        printf 'base64 -d << END_OF_%s | gzip -d | bash\n' $file_hash
        cat "$temp_file" | gzip | base64
        printf 'END_OF_%s\n' $file_hash
        rm "$temp_file"
        #cat
    )
}

(
    cat <<EOF
#!/bin/bash
EOF

    if [ -f "$app_dir/src/help.txt" ]; then
        echo
        echo "############################################################################"
        echo "#"
        cat "$app_dir/src/help.txt" | sed 's/^/# /'
        echo "#"
        echo "############################################################################"
        echo
    fi

    cat <<EOF
set -euo pipefail
tmp_dir=\$(mktemp -d)
trap 'rm -rf "\$tmp_dir"' EXIT
tail -n +\$(( \$(grep -an '^__DATA__\$' "\$0" | cut -d: -f1) + 1 )) "\$0" | (cd \$tmp_dir && bash)
bash \$tmp_dir/$main_script "\$@"
exit \$?
__DATA__
EOF

    (cd src && make_self_extract_script)

) > $dst.tmp
if [ -f "$dst" ] && cmp -s "$dst" "$dst.tmp" >/dev/null; then
    rm "$dst.tmp"
else
    mv "$dst.tmp" "$dst"
    chmod +x $dst
    echo "__APP_NAME__: Updated executable $dst"
fi

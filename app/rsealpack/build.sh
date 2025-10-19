
set -e

app_name=rsealpack

script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
cd $script_dir
source ../../lib/lib.sh

mkdir -p ./etc
build_app ../rselfpack etc && add_gitignore /etc/rselfpack
build_app ../rdockrun etc && add_gitignore /etc/rdockrun
build_app ../rdockrun src && add_gitignore /src/rdockrun

find tool/Dockerfile tool/Cargo.* tool/src -type f -print0 \
    | LC_ALL=C sort -z \
    | xargs -0 sha256sum \
    | sha256sum \
    | awk '{print $1}' \
    > tool-hash.txt.new
if [ ! -f tool-hash.txt ]; then
    touch  tool-hash.txt && add_gitignore /tool-hash.txt
fi
if cmp -s tool-hash.txt tool-hash.txt.new; then
    rm tool-hash.txt.new
else
    (
        volumes=()
        volumes+=("-v" "$script_dir:$script_dir")
        cd tool
        ../etc/rdockrun "${volumes[@]}" ./Dockerfile cargo build --release
    )
    mv tool-hash.txt.new tool-hash.txt
fi

smart_cp tool/target/release/rsealpack src/rsealpack && add_gitignore /src/rsealpack

smart_cp README.md src/help.txt && add_gitignore /src/help.txt

./etc/rselfpack -x --compress src -o ./$app_name.tmp
smart_mv ./$app_name.tmp ./$app_name
chmod +x ./$app_name
add_gitignore /$app_name

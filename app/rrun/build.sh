
set -e

script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
app_name="$(basename "$script_dir")"

cd $script_dir

source ../../lib/lib.sh

mkdir -p ./var/etc

build_app ../rselfpack
smart_cp ../rselfpack/rselfpack ./var/etc/rselfpack

mkdir -p ./var/src
mkdir -p ./var/src/rboxes

smart_cp ./main.sh ./var/src/main.sh

for sub_app in \
        extractmarkdown rdockrun \
        gita gitb gitf gitl gits \
        ll \
    ; do
    build_app ../$sub_app
    smart_cp ../$sub_app/$sub_app ./var/src/rboxes/$sub_app
done

./var/etc/rselfpack -x --compress ./var/src -o ./$app_name.tmp
smart_mv ./$app_name.tmp ./$app_name
chmod +x ./$app_name
add_gitignore /$app_name

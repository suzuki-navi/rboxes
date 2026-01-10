
set -e

script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
app_name="$(basename "$script_dir")"

cd $script_dir

source ../../lib/lib.sh

mkdir -p ./var/etc

build_app ../extractmarkdown
smart_cp ../extractmarkdown/extractmarkdown ./var/etc/extractmarkdown

build_app ../rselfpack
smart_cp ../rselfpack/rselfpack ./var/etc/rselfpack

./var/etc/extractmarkdown src.md -d ./var/src -f

build_app ../rdockrun
smart_cp ../rdockrun/rdockrun ./var/src/rdockrun

smart_cp README.md ./var/src/help.txt

smart_cp dailynote.rb ./var/src/dailynote.rb

./var/etc/rselfpack -x --compress ./var/src -o ./$app_name.tmp
smart_mv ./$app_name.tmp ./$app_name
chmod +x ./$app_name
add_gitignore /$app_name

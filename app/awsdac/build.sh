
set -e

app_name=awsdac

script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
cd $script_dir
source ../../lib/lib.sh

mkdir -p ./etc
build_app ../extractmarkdown etc && add_gitignore /etc/extractmarkdown
build_app ../rselfpack etc && add_gitignore /etc/rselfpack

./etc/extractmarkdown src.md -d src -f
add_gitignore $(etc/extractmarkdown src.md -l | sed 's|^|/src/|')

build_app ../rdockrun src && add_gitignore /src/rdockrun
smart_cp README.md src/help.txt && add_gitignore /src/help.txt

./etc/rselfpack -x --compress src -o ./$app_name.tmp
smart_mv ./$app_name.tmp ./$app_name
chmod +x ./$app_name
add_gitignore /$app_name

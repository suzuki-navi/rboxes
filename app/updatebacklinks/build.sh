
set -e

app_name=updatebacklinks

script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
cd $script_dir
source ../../lib/lib.sh

mkdir -p ./etc
build_app ../rselfpack etc && add_gitignore /etc/rselfpack

mkdir -p ./src
smart_cp updatebacklinks.pl src/updatebacklinks.pl && add_gitignore /src/updatebacklinks.pl
smart_cp README.md src/help.txt && add_gitignore /src/help.txt
echo 'perl $(dirname $0)/updatebacklinks.pl "$@"' > src/main.sh && add_gitignore /src/main.sh

./etc/rselfpack -x --compress src -o ./$app_name.tmp
smart_mv ./$app_name.tmp ./$app_name
chmod +x ./$app_name
add_gitignore /$app_name

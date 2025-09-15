
set -e

app_name=aws

script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
cd $script_dir
source ../../lib/lib.sh

mkdir -p ./etc
build_app ../extractmarkdown etc && add_gitignore /etc/extractmarkdown
build_app ../rselfpack etc && add_gitignore /etc/rselfpack

./etc/extractmarkdown src.md -d src -f
add_gitignore $(etc/extractmarkdown src.md -l | sed 's|^|/src/|')

build_app ../rdockrun src && add_gitignore /src/rdockrun

smart_cp ../../lib/load-env.sh src/load-env.sh && add_gitignore /src/load-env.sh
smart_cp ../../lib/write-env.sh src/write-env.sh && add_gitignore /src/write-env.sh

./etc/rselfpack -x --compress src -o ./$app_name.tmp
smart_mv ./$app_name.tmp ./$app_name
chmod +x ./$app_name
add_gitignore /$app_name

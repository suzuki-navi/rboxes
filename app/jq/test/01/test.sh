
set -e

script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
cd $script_dir
project_dir="$(cd "../.." && pwd)"
source $project_dir/../../lib/lib.sh

$project_dir/jq --help > result.txt
add_gitignore /result.txt
cat result.txt | grep 'jq - commandline JSON processor'


set -e

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd $script_dir
project_dir="$(cd "../.." && pwd)"
source $project_dir/../../lib/lib.sh

$project_dir/markdown2html target.md > result.html
add_gitignore /result.html
cat result.html | grep '<h1>Test Markdown File</h1>'


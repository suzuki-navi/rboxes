
set -e

script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
cd $script_dir
project_dir="$(cd "../.." && pwd)"
source $project_dir/../../lib/lib.sh

# Test 1: Check help output
$project_dir/httpserver --help > result.txt 2>&1 || true
add_gitignore /result.txt
cat result.txt | grep 'httpserver - Simple HTTP server'

echo "Test passed: httpserver help works correctly"

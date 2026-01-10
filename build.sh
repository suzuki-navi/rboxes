
script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

cd $script_dir

source ./lib/lib.sh

for dir in app/*/; do
    app_name=$(basename "$dir")

    echo "Building application: $app_name"
    build_app "app/$app_name" "bin"

    if [ -x "app/$app_name/$app_name" ]; then
        smart_cp "app/$app_name/$app_name" "bin/$app_name"
    else
        echo "No executable found in app/$app_name/$app_name" >&2
    fi
done

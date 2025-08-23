
script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

cd $script_dir

source ./lib/lib.sh

for dir in app/*/; do
    app_name=$(basename "$dir")

    build_app "app/$app_name" "bin"

    # if [ -f "app/$app_name/build.sh" ]; then
    #     (cd "app/$app_name" && bash ./build.sh)
    # fi

    # if [ -x "app/$app_name/$app_name" ]; then
    #     smart_cp "app/$app_name/$app_name" "bin/$app_name"
    # else
    #     echo "No executable found in app/$app_name/$app_name" >&2
    # fi
done

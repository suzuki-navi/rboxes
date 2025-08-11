
script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

cd $script_dir

for dir in app/*/; do
    app_name=$(basename "$dir")
    echo "$app_name: Processing directory"

    if [ -x "app/$app_name/$app_name" ]; then
        if [ -f "bin/$app_name" ] && cmp -s "bin/$app_name" "app/$app_name/$app_name" >/dev/null; then
            :
        else
            cp "app/$app_name/$app_name" "bin/$app_name"
            echo "$app_name: Updated bin/$app_name"
        fi
    else
        echo "$app_name: No executable found in app/$app_name/$app_name"
    fi
done

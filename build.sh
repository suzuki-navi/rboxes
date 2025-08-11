
script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

cd $script_dir

for dir in app/*/; do
    app_name=$(basename "$dir")
    echo "$app_name:"

    if [ -f "app/$app_name/src/docker/entry.sh" ]; then
        cat lib/build-template.sh | sed "s/__APP_NAME__/$app_name/g" > "app/$app_name/build.sh.tmp"
        if [ -f "app/$app_name/build.sh" ] && cmp -s "app/$app_name/build.sh" "app/$app_name/build.sh.tmp" >/dev/null; then
            rm "app/$app_name/build.sh.tmp"
        else
            mv "app/$app_name/build.sh.tmp" "app/$app_name/build.sh"
            echo "    Updated build script $app_name/build.sh"
        fi

        if [ -f "app/$app_name/src/docker/entry2.sh" ] && cmp -s "app/$app_name/src/docker/entry2.sh" "lib/entry2.sh" >/dev/null; then
            :
        else
            cp "lib/entry2.sh" "app/$app_name/src/docker/entry2.sh"
            echo "    Copied entry2 script to app/$app_name/src/docker/entry2.sh"
        fi

        if [ -f "app/$app_name/src/docker/entry3.sh" ] && cmp -s "app/$app_name/src/docker/entry3.sh" "lib/entry3.sh" >/dev/null; then
            :
        else
            cp "lib/entry3.sh" "app/$app_name/src/docker/entry3.sh"
            echo "    Copied entry3 script to app/$app_name/src/docker/entry3.sh"
        fi

        if [ -f "app/$app_name/src/docker/load-env.sh" ] && cmp -s "app/$app_name/src/docker/load-env.sh" "lib/load-env.sh" >/dev/null; then
            :
        else
            cp "lib/load-env.sh" "app/$app_name/src/docker/load-env.sh"
            echo "    Copied load-env script to app/$app_name/src/docker/load-env.sh"
        fi

        if [ -f "app/$app_name/src/docker/write-env.sh" ] && cmp -s "app/$app_name/src/docker/write-env.sh" "lib/write-env.sh" >/dev/null; then
            :
        else
            cp "lib/write-env.sh" "app/$app_name/src/docker/write-env.sh"
            echo "    Copied write-env script to app/$app_name/src/docker/write-env.sh"
        fi

        gitignore_entries=(
            "/$app_name"
            "/build.sh"
            "/src/docker/entry2.sh"
            "/src/docker/entry3.sh"
            "/src/docker/load-env.sh"
            "/src/docker/write-env.sh"
        )
        for entry in "${gitignore_entries[@]}"; do
            if [ ! -f "app/$app_name/.gitignore" ] || ! grep -qxF "$entry" "app/$app_name/.gitignore"; then
                echo "$entry" >> "app/$app_name/.gitignore"
            fi
        done
    fi

    if [ -f "app/$app_name/build.sh" ]; then
        (cd "app/$app_name" && bash ./build.sh)
    fi

    if [ -x "app/$app_name/$app_name" ]; then
        if [ -f "bin/$app_name" ] && cmp -s "bin/$app_name" "app/$app_name/$app_name" >/dev/null; then
            echo "    No changes in executable"
        else
            cp "app/$app_name/$app_name" "bin/$app_name"
            echo "    Updated bin/$app_name"
        fi
    else
        echo "    No executable found in app/$app_name/$app_name"
    fi
done

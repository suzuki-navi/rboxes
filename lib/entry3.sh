input_file="$1"
shift

if [ -f "$HOME/.rx.env" ]; then
    set -a
    source "$HOME/.rx.env"
    set +a
fi

if [ -n "$input_file" ]; then
    exec 0< "$input_file"
fi
bash /app/main.sh "$@"

input_file="$1"
shift
if [ -n "$input_file" ]; then
    exec 0< "$input_file"
fi
bash /app/main.sh "$@"

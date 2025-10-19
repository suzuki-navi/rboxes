
set -e

script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
pwd=$(pwd)

volumes=()

show_help() {
    cat $script_dir/help.txt
}

image_name=""
binname=""
input_path=""
output_path=""
force_overwrite=false
is_debug=false
binary=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            show_help
            exit 0
            ;;
        --image)
            if [ -z "$2" ]; then
                echo "Error: --image requires an image name" >&2
                exit 1
            fi
            image_name="$2"
            shift 2
            ;;
        --binname)
            if [ -z "$2" ]; then
                echo "Error: --binname requires a binary name" >&2
                exit 1
            fi
            binname="$2"
            shift 2
            ;;
        -o|--output)
            if [[ -z "$2" ]]; then
                echo "Error: -o requires an output path" >&2
                exit 1
            fi
            output_name=$(basename "$2")
            output_dir=$(dirname "$2")
            output_dir=$(realpath "$output_dir")
            output_path="$output_dir/$output_name"
            shift 2
            ;;
        -f|--force)
            force_overwrite=true
            shift
            ;;
        --debug)
            is_debug=true
            shift
            ;;
        --binary)
            binary=true
            shift
            ;;
        -*)
            echo "Error: Unknown option $1" >&2
            exit 1
            ;;
        *)
            if [[ -n "$input_path" ]]; then
                echo "Error: Only one argument is allowed." >&2
                exit 1
            fi
            input_path="$1"
            shift
            ;;
    esac
done

if [ -z "$image_name" ] || [ -z "$binname" ]; then
    echo "Error: Both --image and --binname must be specified" >&2
    exit 1
fi

if [[ -z "$output_path" ]]; then
    echo "Error: Output path is not specified." >&2
    exit 1
fi

if ! $force_overwrite; then
    if [[ -e "$output_path" ]]; then
        echo "Error: Output file $output_path already exists. Use -f to overwrite." >&2
        exit 1
    fi
fi

docker_run() {
    image_name="$1"
    shift
    docker run "$image_name" "$@"
}

fetch_expected_option() {
    result_file_path=$(mktemp)
    trap 'rm -f $result_file_path' EXIT

    echo "--expected-path"
    docker_run $image_name sh -c "which $binname" || (echo "Binary not found" >&2; exit 1) >&2

    magic=$(docker_run $image_name sh -c "head -c4 \$(which $binname)" | xxd -p)
    if [ "$magic" != "7f454c46" ]; then
        echo "Not an ELF binary" >&2
        exit 1
    fi

    echo "--expected-hash"
    docker_run $image_name sh -c "cat \$(which $binname)" | sha256sum | awk '{print $1}'
}

option=$(fetch_expected_option)

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p $tmp_dir/rsealpack/src

volumes+=("-v" "$output_path:$output_path")

$script_dir/rsealpack \
    $option \
    --interpreter "$binname" \
    "$input_path" > "$tmp_dir/rsealpack/src/main.rs"

cp "$script_dir/Cargo.toml" "$tmp_dir/rsealpack/"
cp "$script_dir/Cargo.lock" "$tmp_dir/rsealpack/"

(
    volumes=()
    volumes+=("-v" "$tmp_dir:$tmp_dir")
    cd "$tmp_dir/rsealpack"
    $script_dir/rdockrun "${volumes[@]}" "$script_dir/Dockerfile" cargo build --release
)

if $is_debug; then
    cp -r "$tmp_dir/rsealpack" "$pwd/rsealpack-debug-$(date +%Y%m%d_%H%M%S)"
fi

# バイナリのみオプションが指定された場合はバイナリのみ出力
if $binary; then
    cp "$tmp_dir/rsealpack/target/release/rsealpack" "$output_path"
else
    # デフォルトではラッパースクリプトを生成
    # 入力ファイルの拡張子と元のファイル名を取得
    input_ext="${input_path##*.}"

    if [ "$binname" = "perl" ]; then
        bash "$script_dir/wrappers/perl_wrapper.sh" "$tmp_dir/rsealpack/target/release/rsealpack" "$output_path"
    elif [ "$binname" = "bash" ] || [ "$binname" = "sh" ]; then
        bash "$script_dir/wrappers/bash_wrapper.sh" "$tmp_dir/rsealpack/target/release/rsealpack" "$output_path"
    else
        echo "Error: Unsupported binname for wrapper generation: $binname" >&2
        exit 1
    fi
fi

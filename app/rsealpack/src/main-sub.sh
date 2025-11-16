
set -euo pipefail

output_path="$1"

cargo build --release

cp $CARGO_TARGET_DIR/release/rsealpacked "$output_path"

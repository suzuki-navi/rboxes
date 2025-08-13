#!/bin/bash
# Usage: write-env.sh output_file VAR1 VAR2 ...
# Writes environment variables to output_file in a safe format for sourcing.

set -eu

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 output_file VAR1 [VAR2 ...]" >&2
    exit 1
fi

outfile="$1"
shift

for varname in "$@"; do
    if [ "${!varname+x}" ]; then
        # 値を安全にエスケープして export 文として出力
        printf '%s=%q\n' "$varname" "${!varname}"
    fi
done > "$outfile"

if [ -n "${RX_VERBOSE:-}" ]; then
    echo "Environment variables written to $outfile"
    cat "$outfile"
fi

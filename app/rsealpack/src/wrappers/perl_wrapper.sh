
# Perl wrapper generator for rsealpack
# Generates a Perl script that embeds the binary and executes it

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <binary_path> <output_path>" >&2
    exit 1
fi

binary_path="$1"
output_path="$2"

if [ ! -f "$binary_path" ]; then
    echo "Error: Binary file not found: $binary_path" >&2
    exit 1
fi

# バイナリを圧縮してからBase64エンコード（76文字ごとに改行）
binary_b64=$(gzip -c "$binary_path" | base64 -w 76)

# Perlスクリプトを生成
cat > "$output_path" << EOF
use strict;
use warnings;
use File::Temp qw/tempfile tempdir/;
use File::Spec;

my \$binary = <<'BINARY_EOF';
$binary_b64
BINARY_EOF


my \$temp_dir = File::Temp::tempdir() || '/tmp';
my (\$temp_fh, \$tmpbin_filepath) = tempfile('rsealpack_XXXXXX', SUFFIX => '.bin', DIR => \$temp_dir, UNLINK => 1);
close(\$temp_fh);

my (\$b64_fh, \$b64_path) = tempfile('rsealpack_b64_XXXXXX', SUFFIX => '.b64', DIR => \$temp_dir, UNLINK => 1);
print \$b64_fh \$binary;
close(\$b64_fh);

my (\$compressed_fh, \$compressed_path) = tempfile('rsealpack_compressed_XXXXXX', SUFFIX => '.gz', DIR => \$temp_dir, UNLINK => 1);
close(\$compressed_fh);
system("base64 -d '\$b64_path' > '\$compressed_path'") == 0
    or die "Failed to decode with base64 command: \$!";

system("gunzip -c '\$compressed_path' > '\$tmpbin_filepath'") == 0
    or die "Failed to decompress binary data: \$!";

chmod(0755, \$tmpbin_filepath);

my @cmd = (\$tmpbin_filepath, @ARGV);

exec(@cmd) or die "exec failed: \$!";
EOF

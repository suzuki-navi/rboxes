
set -e

script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
cd $script_dir
project_dir="$(cd "../.." && pwd)"
source $project_dir/../../lib/lib.sh

########

$project_dir/rsealpack ./sample.pl -o ./sample.pl.bin --image debian:bookworm --binname perl -f --binary
add_gitignore /sample.pl.bin

docker run -v $script_dir:$script_dir -w $script_dir debian:bookworm ./sample.pl.bin > actual-perl-bin.txt
add_gitignore /actual-perl-bin.txt

diff -u expected.txt actual-perl-bin.txt

$project_dir/rsealpack ./sample.pl -o ./sample.pl.bin.pl --image debian:bookworm --binname perl -f
add_gitignore /sample.pl.bin.pl

docker run -v $script_dir:$script_dir -w $script_dir debian:bookworm perl ./sample.pl.bin.pl > actual-perl-script.txt
add_gitignore /actual-perl-script.txt

diff -u expected.txt actual-perl-script.txt

########

$project_dir/rsealpack ./sample.sh -o ./sample.sh.bin --image debian:bookworm --binname bash -f --binary
add_gitignore /sample.sh.bin

docker run -v $script_dir:$script_dir -w $script_dir debian:bookworm ./sample.sh.bin > actual-bash-bin.txt
add_gitignore /actual-bash-bin.txt

diff -u expected.txt actual-bash-bin.txt

$project_dir/rsealpack ./sample.sh -o ./sample.sh.bin.sh --image debian:bookworm --binname bash -f
add_gitignore /sample.sh.bin.sh

docker run -v $script_dir:$script_dir -w $script_dir debian:bookworm bash ./sample.sh.bin.sh > actual-bash-script.txt
add_gitignore /actual-bash-script.txt

diff -u expected.txt actual-bash-script.txt

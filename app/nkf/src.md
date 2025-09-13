## Dockerfile

```text Dockerfile
FROM debian:bookworm
RUN apt update
RUN apt install -y nkf
```

## main.sh

```bash main.sh

script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
pwd=$(pwd)

volumes=()
volumes+=("-v" "$pwd:$pwd")

$script_dir/rdockrun "${volumes[@]}" $script_dir nkf "$@"
```

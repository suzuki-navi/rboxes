## Dockerfile

```text Dockerfile
FROM python:3.13-bookworm
RUN apt update
RUN apt install -y jq
RUN pip install yq
COPY . /app
```

## main.sh

```bash main.sh

script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
pwd=$(pwd)

volumes=()
volumes+=("-v" "$pwd:$pwd")

$script_dir/rdockrun "${volumes[@]}" $script_dir yq "$@"
```


## Dockerfile
```text Dockerfile
FROM python:3.13.5-bookworm
COPY requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

COPY . /app
```

## requirements.txt
```text requirements.txt
aws-list-subnets
```

## main.sh
```bash main.sh
script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
pwd=$(pwd)

TMP_DIR=$(mktemp -d)
CLEANUP_DIRS=("$TMP_DIR")
trap 'rm -rf "${CLEANUP_DIRS[@]}"' EXIT

volumes=()

source $script_dir/load-env.sh
bash $script_dir/write-env.sh "$TMP_DIR/.rx.env" \
    AWS_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY \
    AWS_REGION \
    ;

$script_dir/rdockrun "${volumes[@]}" --envfile "$TMP_DIR/.rx.env" $script_dir aws-list-subnets "$@"
```

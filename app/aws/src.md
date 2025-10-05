## Dockerfile

```text Dockerfile
FROM debian:bookworm
RUN apt update
RUN apt install -y mandoc less curl unzip

WORKDIR /usr/local

# Install AWS CLI v2
RUN curl -SsfLk "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscli-exe-linux-x86_64.zip
RUN unzip awscli-exe-linux-x86_64.zip
RUN ./aws/install --bin-dir /usr/local/aws/bin/

ENV PATH /usr/local/aws/bin:$PATH
```

## main.sh

```bash main.sh
script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
pwd=$(pwd)

TMP_DIR=$(mktemp -d)
CLEANUP_DIRS=("$TMP_DIR")
trap 'rm -rf "${CLEANUP_DIRS[@]}"' EXIT

volumes=()
volumes+=("-v" "$pwd:$pwd")

source $script_dir/load-env.sh
bash $script_dir/write-env.sh "$TMP_DIR/.rx.env" \
    AWS_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY \
    AWS_REGION \
    ;

$script_dir/rdockrun "${volumes[@]}" --envfile "$TMP_DIR/.rx.env" $script_dir aws "$@"
```


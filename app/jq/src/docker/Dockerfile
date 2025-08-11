FROM debian:bookworm
RUN apt update
RUN apt install -y jq
COPY . /app
ENTRYPOINT ["/bin/bash", "/app/docker/entry3.sh"]

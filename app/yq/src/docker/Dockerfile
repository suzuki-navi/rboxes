FROM python:3.13-bookworm
RUN apt update
RUN apt install -y jq
RUN pip install yq
COPY . /app
ENTRYPOINT ["/bin/bash", "/app/docker/entry3.sh"]

FROM python:3.13-bookworm

RUN apt update
RUN apt install -y poppler-utils

COPY requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

#RUN locale-gen ja_JP.UTF-8

COPY . /app
ENTRYPOINT ["/bin/bash", "/app/docker/entry3.sh"]

FROM python:3.13-bookworm

RUN apt update
RUN apt install -y libreoffice
RUN apt install -y fonts-noto-cjk fonts-noto-cjk-extra locales

RUN locale-gen ja_JP.UTF-8

COPY . /app
ENTRYPOINT ["/bin/bash", "/app/docker/entry3.sh"]

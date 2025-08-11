FROM python:3.11-slim

COPY requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

COPY . /app
ENTRYPOINT ["/bin/bash", "/app/docker/entry3.sh"]

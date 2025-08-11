FROM node:24-bookworm
RUN npm install -g @anthropic-ai/claude-code

COPY . /app
ENTRYPOINT ["/bin/bash", "/app/docker/entry3.sh"]

FROM ruby:3.2-slim

RUN gem install unicode-display_width

COPY . /app
ENTRYPOINT ["/bin/bash", "/app/docker/entry3.sh"]
FROM ruby:3.4.4-bookworm
RUN gem install specific_install
RUN gem specific_install -l https://github.com/suzuki-navi/suzuki-navi-calendar.git
COPY . /app
ENTRYPOINT ["/bin/bash", "/app/docker/entry3.sh"]

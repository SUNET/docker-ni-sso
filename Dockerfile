FROM debian:bullseye

RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get install -y \
      git \
      curl \
      build-essential \
      libpython3-dev \
      python3-venv \
      libpq-dev \
      libffi-dev \
      python3-dev \
      libxml2-dev \
      libxslt1-dev \
      xmlsec1 \
      libxml2-utils \
    && apt-get clean

RUN git clone https://github.com/SUNET/ni-sso.git /opt/ni
WORKDIR /opt/ni
RUN git checkout magnus-sso

COPY docker/setup.sh /setup.sh
RUN /setup.sh

COPY docker/set-initial-neo4j-password.sh /usr/local/bin/set-initial-neo4j-password
COPY docker/run-django-cmd.sh /usr/local/bin/run-django-cmd
COPY docker/backup-neo4j.sh /usr/local/bin/backup-neo4j.sh
COPY docker/start.sh /start.sh

# Add Dockerfile to the container as documentation
COPY Dockerfile /Dockerfile

VOLUME ["/opt/ni", "/var/log/ni", "/opt/ni/src/niweb/niweb/static"]

WORKDIR /

EXPOSE 8080

ENTRYPOINT ["/start.sh"]

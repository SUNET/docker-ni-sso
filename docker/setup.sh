#!/bin/bash
#
# Install all requirements
#

set -e
set -x

virtualenv /opt/ni/env

addgroup --system ni
adduser --system --shell /bin/false ni

mkdir -p /var/log/ni
chown -R ni:root /var/log/ni

mkdir -p /opt/ni
chown -R ni:ni /opt/ni

mkdir -p /opt/ni/run
chown -R ni:ni /opt/ni/run

mkdir -p /opt/ni/staticfiles
chown -R ni:ni /opt/ni/staticfiles

mkdir -p /opt/ni/media
chown -R ni:ni /opt/ni/media

mkdir -p /tmp/django_cache
chown -R ni:ni /tmp/django_cache

cd /opt/ni

PYPI="https://pypi.sunet.se/simple/"
/opt/ni/env/bin/pip install -i ${PYPI} -r requirements/prod.txt
/opt/ni/env/bin/pip install gunicorn

/opt/ni/env/bin/pip freeze


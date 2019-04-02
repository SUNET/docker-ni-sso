#!/bin/sh

export DJANGO_SETTINGS_MODULE=niweb.settings.prod

/opt/ni/env/bin/python /opt/ni/src/niweb/manage.py "$@"

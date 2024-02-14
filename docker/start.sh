#!/bin/sh

set -e
set -x

. /opt/ni/env/bin/activate

# These could be set from Puppet if multiple instances are deployed
base_dir=${base_dir-"/opt/ni"}
name=${name-"noclook"}
django_settings_module=${django_settings_module-"niweb.settings.prod"}
# These *can* be set from Puppet, but are less expected to...
project_dir=${project_dir-"${base_dir}/src/niweb"}
log_dir=${log_dir-'/var/log/ni'}
state_dir=${state_dir-"${base_dir}/run"}
media_dir=${media_dir-"${base_dir}/media"}
backup_dir=${backup_dir-"${base_dir}/backup"}
cache_dir="/tmp/django_cache/"
workers=${workers-2}
worker_class=${worker_class-sync}
worker_threads=${worker_threads-4}
worker_timeout=${worker_timeout-30}
# gunicorn_args="--bind 0.0.0.0:8080 --worker-tmp-dir /dev/shm -w ${workers} -k ${worker_class} --threads ${worker_threads} -t ${worker_timeout} niweb.wsgi"
### ADDED-----
gunicorn_args="--bind 0.0.0.0:8080 --capture-output --access-logfile /var/log/ni/gunicorn.access.log --error-logfile /var/log/ni/gunicorn.error.log --worker-tmp-dir /dev/shm -w ${workers} -k ${worker_class} --threads ${worker_threads} -t ${worker_timeout} niweb.wsgi"
### ADDED-----

# set PYTHONPATH if it is not already set using Docker environment
export PYTHONPATH=${PYTHONPATH-${project_dir}}

# nice to have in docker run output, to check what
# version of something is actually running.
/opt/ni/env/bin/pip freeze

# Wait for neo4j container accept connections
sleep 5

export LOG_PATH=${log_dir}
export DJANGO_SETTINGS_MODULE=${django_settings_module}

# Migrate db
/opt/ni/env/bin/python /opt/ni/src/niweb/manage.py migrate --noinput
# Collect static files
/opt/ni/env/bin/python /opt/ni/src/niweb/manage.py collectstatic --noinput

mkdir -p "${log_dir}" "${state_dir}" "${media_dir}" "${cache_dir}" "${backup_dir}"
chown -R ni: "${log_dir}" "${state_dir}" "${media_dir}" "${cache_dir}" "${backup_dir}"

### ADDED-----
touch /var/log/ni/gunicorn.access.log
touch /var/log/ni/gunicorn.error.log
chmod 764 /var/log/ni/gunicorn.access.log
chmod 764 /var/log/ni/gunicorn.error.log
### ADDED-----

start-stop-daemon --start -c ni:ni --exec \
     /opt/ni/env/bin/gunicorn \
     --pidfile "${state_dir}/${name}.pid" \
     --user=ni --group=ni -- $gunicorn_args


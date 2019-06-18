#!/usr/bin/env bash
#
# Simplistic neo4j backup
#
set -e

BACKUPROOT=${BACKUPROOT-"/opt/ni/backup"}
BACKUPPYTHONENV=${BACKUPPYTHONENV-"/opt/ni/env"}
BACKUPSCRIPTPATH=${BACKUPSCRIPTPATH-"/opt/ni/src/scripts"}

if [ ! -d ${BACKUPROOT} ]; then
    echo "$0: Directory ${BACKUPROOT} does not exist - aborting."
    exit 1
fi

if [ ! -d ${BACKUPPYTHONENV} ]; then
    echo "$0: Directory ${BACKUPPYTHONENV} does not exist - aborting."
    exit 1
fi

if [ ! -d ${BACKUPSCRIPTPATH} ]; then
    echo "$0: Directory ${BACKUPSCRIPTPATH} does not exist - aborting."
    exit 1
fi

# keep ten runs worth of dumps
rm -rf ${BACKUPROOT}/neo4j-backup.tar.gz.10
test -f ${BACKUPROOT}/neo4j-backup.tar.gz.9 && mv ${BACKUPROOT}/neo4j-backup.tar.gz.9 ${BACKUPROOT}/neo4j-backup.tar.gz.10
test -f ${BACKUPROOT}/neo4j-backup.tar.gz.8 && mv ${BACKUPROOT}/neo4j-backup.tar.gz.8 ${BACKUPROOT}/neo4j-backup.tar.gz.9
test -f ${BACKUPROOT}/neo4j-backup.tar.gz.7 && mv ${BACKUPROOT}/neo4j-backup.tar.gz.7 ${BACKUPROOT}/neo4j-backup.tar.gz.8
test -f ${BACKUPROOT}/neo4j-backup.tar.gz.6 && mv ${BACKUPROOT}/neo4j-backup.tar.gz.6 ${BACKUPROOT}/neo4j-backup.tar.gz.7
test -f ${BACKUPROOT}/neo4j-backup.tar.gz.5 && mv ${BACKUPROOT}/neo4j-backup.tar.gz.5 ${BACKUPROOT}/neo4j-backup.tar.gz.6
test -f ${BACKUPROOT}/neo4j-backup.tar.gz.4 && mv ${BACKUPROOT}/neo4j-backup.tar.gz.4 ${BACKUPROOT}/neo4j-backup.tar.gz.5
test -f ${BACKUPROOT}/neo4j-backup.tar.gz.3 && mv ${BACKUPROOT}/neo4j-backup.tar.gz.3 ${BACKUPROOT}/neo4j-backup.tar.gz.4
test -f ${BACKUPROOT}/neo4j-backup.tar.gz.2 && mv ${BACKUPROOT}/neo4j-backup.tar.gz.2 ${BACKUPROOT}/neo4j-backup.tar.gz.3
test -f ${BACKUPROOT}/neo4j-backup.tar.gz.1 && mv ${BACKUPROOT}/neo4j-backup.tar.gz.1 ${BACKUPROOT}/neo4j-backup.tar.gz.2

echo "Running neo4j backup..."
cd ${BACKUPROOT}

. $BACKUPPYTHONENV/bin/activate
mkdir -p $BACKUPROOT/json/
$BACKUPSCRIPTPATH/noclook_producer.py -O $BACKUPROOT/json/
/bin/tar -czf $BACKUPROOT/neo4j-backup.tar.gz ./json/* --remove-files
rmdir $BACKUPROOT/json/

mv ${BACKUPROOT}/neo4j-backup.tar.gz ${BACKUPROOT}/neo4j-backup.tar.gz.1
echo "...done."


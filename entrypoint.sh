#!/bin/sh
set -e

echo "***** Start SSH server *****"
/usr/sbin/sshd

echo "***** Start migrate database *****"
python manage.py migrate

exec "$@"

#!/bin/bash
set -e

echo "***** Start SSH server *****"
service ssh start

echo "***** Start migrate database *****"
python manage.py migrate

exec "$@"

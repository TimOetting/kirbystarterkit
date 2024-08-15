#!/bin/bash

set -e -u


if grep -q kirby /etc/group
then
  echo "kirby group already exists, skipping"
else
  echo "creating kirby group and user with uid ${KIRBY_UID} and gid ${KIRBY_GID}"
  [[ $KIRBY_GID ]] && addgroup --system --gid "${KIRBY_GID}" kirby
  [[ $KIRBY_UID ]] && adduser --system --disabled-password --shell /bin/sh --uid "${KIRBY_UID}" kirby \
  && adduser kirby kirby

  echo "setting kirby as the apache user"
  sed -i "s/export APACHE_RUN_USER=www-data/export APACHE_RUN_USER=kirby/g" /etc/apache2/envvars
  sed -i "s/export APACHE_RUN_GROUP=www-data/export APACHE_RUN_GROUP=kirby/g" /etc/apache2/envvars

  echo "changing owner of all cms files to kirby"
  chown -R kirby:kirby /var/www/html/
fi

exec "$@"

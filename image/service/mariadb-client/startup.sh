#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

FIRST_START_DONE="${CONTAINER_STATE_DIR}/docker-mariadb-client-first-start-done"
# container first start
if [ ! -e "${FIRST_START_DONE}" ]; then

  if [ "${MATTERMOST_LDAP_MARIADB_CLIENT_TLS,,}" == "true" ]; then
    # generate a certificate and key if files don't exists
    # https://github.com/osixia/docker-light-baseimage/blob/stable/image/service-available/:ssl-tools/assets/tool/ssl-helper
    ssl-helper "${MARIADB_CLIENT_SSL_HELPER_PREFIX}" "${CONTAINER_SERVICE_DIR}/mariadb-client/assets/certs/${MATTERMOST_LDAP_MARIADB_CLIENT_TLS_CRT_FILENAME}" "${CONTAINER_SERVICE_DIR}/mariadb-client/assets/certs/${MATTERMOST_LDAP_MARIADB_CLIENT_TLS_KEY_FILENAME}" "${CONTAINER_SERVICE_DIR}/mariadb-client/assets/certs/${MATTERMOST_LDAP_MARIADB_CLIENT_TLS_CA_CRT_FILENAME}"

    chown www-data:www-data -R "${CONTAINER_SERVICE_DIR}/mariadb-client/assets/certs/"
  fi

  touch "${FIRST_START_DONE}"
fi

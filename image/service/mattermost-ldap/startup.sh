#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

FIRST_START_DONE="${CONTAINER_STATE_DIR}/mattermost-ldap-first-start-done"
if [ ! -e "${FIRST_START_DONE}" ]; then
    
    #
    # LDAP configuration
    #
    log-helper info "Set ldap config..."
    sed -i "s|{{ MATTERMOST_LDAP_LDAP_HOST }}|${MATTERMOST_LDAP_LDAP_HOST}|g" "${CONTAINER_SERVICE_DIR}/mattermost-ldap/assets/config/config_ldap.php"
    sed -i "s|{{ MATTERMOST_LDAP_LDAP_PORT }}|${MATTERMOST_LDAP_LDAP_PORT}|g" "${CONTAINER_SERVICE_DIR}/mattermost-ldap/assets/config/config_ldap.php"
    sed -i "s|{{ MATTERMOST_LDAP_LDAP_VERSION }}|${MATTERMOST_LDAP_LDAP_VERSION}|g" "${CONTAINER_SERVICE_DIR}/mattermost-ldap/assets/config/config_ldap.php"
    sed -i "s|{{ MATTERMOST_LDAP_LDAP_SEARCH_ATTRIBUTE }}|${MATTERMOST_LDAP_LDAP_SEARCH_ATTRIBUTE}|g" "${CONTAINER_SERVICE_DIR}/mattermost-ldap/assets/config/config_ldap.php"
    sed -i "s|{{ MATTERMOST_LDAP_LDAP_BASE_DN }}|${MATTERMOST_LDAP_LDAP_BASE_DN}|g" "${CONTAINER_SERVICE_DIR}/mattermost-ldap/assets/config/config_ldap.php"
    sed -i "s|{{ MATTERMOST_LDAP_LDAP_FILTER }}|${MATTERMOST_LDAP_LDAP_FILTER}|g" "${CONTAINER_SERVICE_DIR}/mattermost-ldap/assets/config/config_ldap.php"
    sed -i "s|{{ MATTERMOST_LDAP_LDAP_BIND_DN }}|${MATTERMOST_LDAP_LDAP_BIND_DN}|g" "${CONTAINER_SERVICE_DIR}/mattermost-ldap/assets/config/config_ldap.php"
    sed -i "s|{{ MATTERMOST_LDAP_LDAP_BIND_PASSWORD }}|${MATTERMOST_LDAP_LDAP_BIND_PASSWORD}|g" "${CONTAINER_SERVICE_DIR}/mattermost-ldap/assets/config/config_ldap.php"
    
    #
    # DB configuration
    #
    log-helper info "Set database config..."
    sed -i "s|{{ MATTERMOST_LDAP_MARIADB_PORT }}|${MATTERMOST_LDAP_MARIADB_PORT}|g" "${CONTAINER_SERVICE_DIR}/mattermost-ldap/assets/config/config_db.php"
    sed -i "s|{{ MATTERMOST_LDAP_MARIADB_HOST }}|${MATTERMOST_LDAP_MARIADB_HOST}|g" "${CONTAINER_SERVICE_DIR}/mattermost-ldap/assets/config/config_db.php"
    sed -i "s|{{ MATTERMOST_LDAP_MARIADB_DATABASE }}|${MATTERMOST_LDAP_MARIADB_DATABASE}|g" "${CONTAINER_SERVICE_DIR}/mattermost-ldap/assets/config/config_db.php"
    sed -i "s|{{ MATTERMOST_LDAP_MARIADB_USER }}|${MATTERMOST_LDAP_MARIADB_USER}|g" "${CONTAINER_SERVICE_DIR}/mattermost-ldap/assets/config/config_db.php"
    sed -i "s|{{ MATTERMOST_LDAP_MARIADB_PASSWORD }}|${MATTERMOST_LDAP_MARIADB_PASSWORD}|g" "${CONTAINER_SERVICE_DIR}/mattermost-ldap/assets/config/config_db.php"
    sed -i "s|{{ MATTERMOST_LDAP_DATE_TIMEZONE }}|${MATTERMOST_LDAP_DATE_TIMEZONE}|g" "${CONTAINER_SERVICE_DIR}/mattermost-ldap/assets/config/config_db.php"
    
    #
    # DB initialisation
    #
    mysql=(mysql -h "${MATTERMOST_LDAP_MARIADB_HOST}" -P "${MATTERMOST_LDAP_MARIADB_PORT}" -u "${MATTERMOST_LDAP_MARIADB_USER}" -p"${MATTERMOST_LDAP_MARIADB_PASSWORD}" "${MATTERMOST_LDAP_MARIADB_DATABASE}")
    
    for _ in {30..0}; do
        if "${mysql[@]}" -e "select 1;" &> /dev/null; then
            break
        fi
        log-helper info "Waiting database connection..."
        sleep 1
    done
    
    if [ -z "${MATTERMOST_LDAP_OAUTH_CLIENT_ID}" ]; then
        log-helper warning "MATTERMOST_LDAP_OAUTH_CLIENT_ID is not set, going to generate a new client id and add it to the database everytime a container is created."
        MATTERMOST_LDAP_OAUTH_CLIENT_ID=$(openssl rand -hex 32)
    fi
    
    if [ -z "${MATTERMOST_LDAP_OAUTH_CLIENT_SECRET}" ]; then
        MATTERMOST_LDAP_OAUTH_CLIENT_SECRET=$(openssl rand -hex 32)
    fi
    
    log-helper info "Create database schema..."
    "${mysql[@]}" -e "CREATE TABLE IF NOT EXISTS oauth_clients (client_id VARCHAR(80) NOT NULL, client_secret VARCHAR(80), redirect_uri VARCHAR(2000) NOT NULL, grant_types VARCHAR(80), scope VARCHAR(100), user_id VARCHAR(80), CONSTRAINT clients_client_id_pk PRIMARY KEY (client_id));"
    "${mysql[@]}" -e "CREATE TABLE IF NOT EXISTS oauth_access_tokens (access_token VARCHAR(40) NOT NULL, client_id VARCHAR(80) NOT NULL, user_id VARCHAR(255), expires TIMESTAMP NOT NULL, scope VARCHAR(2000), CONSTRAINT access_token_pk PRIMARY KEY (access_token));"
    "${mysql[@]}" -e "CREATE TABLE IF NOT EXISTS oauth_authorization_codes (authorization_code VARCHAR(40) NOT NULL, client_id VARCHAR(80) NOT NULL, user_id VARCHAR(255), redirect_uri VARCHAR(2000), expires TIMESTAMP NOT NULL, scope VARCHAR(2000), CONSTRAINT auth_code_pk PRIMARY KEY (authorization_code));"
    "${mysql[@]}" -e "CREATE TABLE IF NOT EXISTS oauth_refresh_tokens (refresh_token VARCHAR(40) NOT NULL, client_id VARCHAR(80) NOT NULL, user_id VARCHAR(255), expires TIMESTAMP NOT NULL, scope VARCHAR(2000), CONSTRAINT refresh_token_pk PRIMARY KEY (refresh_token));"
    "${mysql[@]}" -e "CREATE TABLE IF NOT EXISTS users (id SERIAL NOT NULL, username VARCHAR(255) NOT NULL, CONSTRAINT id_pk PRIMARY KEY (id));"
    "${mysql[@]}" -e "CREATE TABLE IF NOT EXISTS oauth_scopes (scope TEXT, is_default BOOLEAN);"
    
    log-helper info "Create oauth2 client..."
    "${mysql[@]}" -e "INSERT IGNORE INTO oauth_clients (client_id,client_secret,redirect_uri,grant_types,scope,user_id) VALUES ('${MATTERMOST_LDAP_OAUTH_CLIENT_ID}','${MATTERMOST_LDAP_OAUTH_CLIENT_SECRET}','${MATTERMOST_LDAP_REDIRECT_URI}','${MATTERMOST_LDAP_OAUTH_GRANT_TYPE}','${MATTERMOST_LDAP_OAUTH_SCOPE}','docker-mattermost-ldap-mysql-init');"
    
    log-helper info "Client ID : ${MATTERMOST_LDAP_OAUTH_CLIENT_ID}"
    log-helper info "Client Secret : ${MATTERMOST_LDAP_OAUTH_CLIENT_SECRET}"
    
    touch "${FIRST_START_DONE}"
fi

#
# Link configs
#
ln -sf "${CONTAINER_SERVICE_DIR}/mattermost-ldap/assets/config/config_ldap.php" /var/www/mattermost-ldap/oauth/LDAP/config_ldap.php
ln -sf "${CONTAINER_SERVICE_DIR}/mattermost-ldap/assets/config/config_db.php" /var/www/mattermost-ldap/oauth/config_db.php

#
# HTTPS config
#
if [ "${MATTERMOST_LDAP_HTTPS,,}" == "true" ]; then
    
    log-helper info "Set apache2 https config..."
    
    # generate a certificate and key if files don't exists
    # https://github.com/osixia/docker-light-baseimage/blob/stable/image/service-available/:ssl-tools/assets/tool/ssl-helper
    ssl-helper "${MATTERMOST_LDAP_SSL_HELPER_PREFIX}" "${CONTAINER_SERVICE_DIR}/mattermost-ldap/assets/apache2/certs/${MATTERMOST_LDAP_HTTPS_CRT_FILENAME}" "${CONTAINER_SERVICE_DIR}/mattermost-ldap/assets/apache2/certs/${MATTERMOST_LDAP_HTTPS_KEY_FILENAME}" "${CONTAINER_SERVICE_DIR}/mattermost-ldap/assets/apache2/certs/${MATTERMOST_LDAP_HTTPS_CA_CRT_FILENAME}"
    
    # add CA certificat config if CA cert exists
    if [ -e "${CONTAINER_SERVICE_DIR}/mattermost-ldap/assets/apache2/certs/${MATTERMOST_LDAP_HTTPS_CA_CRT_FILENAME}" ]; then
        sed -i "s/#SSLCACertificateFile/SSLCACertificateFile/g" "${CONTAINER_SERVICE_DIR}/mattermost-ldap/assets/apache2/https.conf"
    fi
    
    ln -sf "${CONTAINER_SERVICE_DIR}/mattermost-ldap/assets/apache2/https.conf" /etc/apache2/sites-available/mattermost-ldap.conf
    #
    # HTTP config
    #
else
    log-helper info "Set apache2 http config..."
    ln -sf "${CONTAINER_SERVICE_DIR}/mattermost-ldap/assets/apache2/http.conf" /etc/apache2/sites-available/mattermost-ldap.conf
fi

a2ensite mattermost-ldap | log-helper debug



# Fix file permission
find /var/www/ -type d -exec chmod 755 {} \;
find /var/www/ -type f -exec chmod 644 {} \;
chown www-data:www-data -R /var/www

FROM osixia/web-baseimage:1.2.0

# mattermost-ldap version
ARG MATTERMOST_LDAP_VERSION=1.0.1
ARG MATTERMOST_LDAP_GIT_REPO=https://github.com/osixia/Mattermost-LDAP.git

# MariaDB version
ARG MARIADB_MAJOR=10.3

# Install apache2 and php7.3-fpm using osixia/baseimage utils
# Caution: /container/tool/install-service-available arguments order is important
# php7.3-fpm install will detect apache2 and configure it

# Add MariaDB repository
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8 \
  && echo "deb http://ftp.igh.cnrs.fr/pub/mariadb/repo/$MARIADB_MAJOR/debian stretch main" > /etc/apt/sources.list.d/mariadb.list \
  && { \
  echo 'Package: *'; \
  echo 'Pin: release o=MariaDB'; \
  echo 'Pin-Priority: 999'; \
  } > /etc/apt/preferences.d/mariadb

RUN apt-get update \
  && /container/tool/add-multiple-process-stack \
  && /container/tool/add-service-available :apache2 :php7.3-fpm :ssl-tools \
  && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  git \
  mariadb-client-${MARIADB_MAJOR} \
  php \
  php-ldap \
  php-mysql \
  php-pdo \
  && git clone ${MATTERMOST_LDAP_GIT_REPO} mattermost-ldap \
  && cd mattermost-ldap && git fetch && git fetch --tags \
  && git checkout v${MATTERMOST_LDAP_VERSION} \
  && mkdir -p /var/www/mattermost-ldap && cp -r oauth /var/www/mattermost-ldap \
  && rm -rf mattermost-ldap \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add service directory to /container/service
ADD service /container/service

# Use baseimage install-service script
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/install-service
RUN /container/tool/install-service

# Add default env variables
ADD environment /container/environment/99-default

# Set backup directory in a data volume
VOLUME ["/data/backup"]

# Expose http and https default ports
EXPOSE 80 443

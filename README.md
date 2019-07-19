# osixia/mattermost-ldap

![Docker Pulls](https://img.shields.io/docker/pulls/osixia/mattermost-ldap.svg)
![Docker Stars](https://img.shields.io/docker/stars/osixia/mattermost-ldap.svg)
![](https://images.microbadger.com/badges/image/osixia/mattermost-ldap.svg)

Latest release: 1.0.0 - Mattermost-LDAP 1.0.0 - [Changelog](CHANGELOG.md) | [Docker Hub](https://hub.docker.com/r/osixia/mattermost-ldap/) 

**A docker image to run Mattermost-LDAP.**

> Mattermost-LDAP website : [github.com/Crivaledaz/Mattermost-LDAP](https://github.com/Crivaledaz/Mattermost-LDAP)


- [osixia/mattermost-ldap](#osixiamattermost-ldap)
	- [Contributing](#Contributing)
	- [Quick Start](#Quick-Start)
	- [Beginner Guide](#Beginner-Guide)
		- [TLS](#TLS)
			- [Use auto-generated certificate](#Use-auto-generated-certificate)
			- [Use your own certificate](#Use-your-own-certificate)
			- [Disable TLS](#Disable-TLS)
		- [Debug](#Debug)
	- [Environment Variables](#Environment-Variables)
		- [Default.yaml](#Defaultyaml)
		- [Default.startup.yaml](#Defaultstartupyaml)
		- [Set your own environment variables](#Set-your-own-environment-variables)
			- [Use command line argument](#Use-command-line-argument)
			- [Link environment file](#Link-environment-file)
			- [Make your own image or extend this image](#Make-your-own-image-or-extend-this-image)
	- [Advanced User Guide](#Advanced-User-Guide)
		- [Extend osixia/mattermost-ldap:1.0.0 image](#Extend-osixiamattermost-ldap100-image)
		- [Make your own image](#Make-your-own-image)
		- [Tests](#Tests)
		- [Kubernetes](#Kubernetes)
		- [Under the hood: osixia/light-baseimage](#Under-the-hood-osixialight-baseimage)
	- [Security](#Security)
	- [Changelog](#Changelog)

## Contributing

If you find this image useful here's how you can help:

- Send a pull request with your kickass new features and bug fixes
- Help new users with [issues](https://github.com/osixia/docker-openldap/issues) they may encounter
- Support the development of this image and star this repo !

## Quick Start

Take a look at the kubernetes example in **example/kubernetes**

## Beginner Guide

### TLS

#### Use auto-generated certificate
By default, TLS is already configured and enabled, certificate is created using container hostname (it can be set by docker run --hostname option eg: mattermost-ldap.example.org).

	docker run --hostname mattermost-ldap.my-company.com --detach osixia/mattermost-ldap:1.0.0

#### Use your own certificate

You can set your custom certificate at run time, by mounting a directory containing those files to **/container/service/mattermost-ldap/assets/apache2/certs** and adjust their name with the following environment variables:

	docker run --hostname mattermost-ldap.example.org --volume /path/to/certificates:/container/service/mattermost-ldap/assets/apache2/certs \
	--env MATTERMOST_LDAP_HTTPS_CRT_FILENAME=my-ldap.crt \
	--env MATTERMOST_LDAP_HTTPS_KEY_FILENAME=my-ldap.key \
	--env MATTERMOST_LDAP_HTTPS_CA_CRT_FILENAME=the-ca.crt \
	--detach osixia/mattermost-ldap:1.0.0

Other solutions are available please refer to the [Advanced User Guide](#advanced-user-guide)

#### Disable TLS
Add --env MATTERMOST_LDAP_HTTPS=false to the run command:

	docker run --env MATTERMOST_LDAP_HTTPS=false --detach osixia/mattermost-ldap:1.0.0

### Debug

The container default log level is **info**.
Available levels are: `none`, `error`, `warning`, `info`, `debug` and `trace`.

Example command to run the container in `debug` mode:

	docker run --detach osixia/mattermost-ldap:1.0.0 --loglevel debug

See all command line options:

	docker run osixia/mattermost-ldap:1.0.0 --help


## Environment Variables
Environment variables defaults are set in **image/environment/default.yaml** and **image/environment/default.startup.yaml**.

See how to [set your own environment variables](#set-your-own-environment-variables)

### Default.yaml
Variables defined in this file are available at anytime in the container environment.

General container configuration:
- **MATTERMOST_LDAP_BACKUP_CRON_EXP**: Cron expression to schedule mattermost ldap database backup. Defaults to `* 4 * * *`. Every days at 4am.

- **MATTERMOST_LDAP_BACKUP_TTL**: Backup TTL in days. Defaults to `15`.

Apache:
- **MATTERMOST_LDAP_SERVER_ADMIN**: Apache admin email. Defaults to `webmaster@example.org`.
- **MATTERMOST_LDAP_SERVER_PATH**: Server path. Default to `/mattermost-ldap`.

TLS options:
- **MATTERMOST_LDAP_HTTPS**: Enable HTTPS. Defaults to `true`.
- **MATTERMOST_LDAP_HTTPS_CRT_FILENAME**: Https certificate filename. Defaults to `mattermost-ldap.crt`
- **MATTERMOST_LDAP_HTTPS_KEY_FILENAME**: Https certificate private key filename. Defaults to `mattermost-ldap.key`
- **MATTERMOST_LDAP_HTTPS_CA_CRT_FILENAME**: Https CA certificate filename. Defaults to `ca.crt`

- **MATTERMOST_LDAP_SSL_HELPER_PREFIX**: ssl-helper environment variables prefix. Defaults to `mattermost`, ssl-helper first search config from MATTERMOST_SSL_HELPER_* variables, before SSL_HELPER_* variables.


### Default.startup.yaml
Variables defined in this file are only available during the container **first start** in **startup files**.
This file is deleted right after startup files are processed for the first time,
then all of these values will not be available in the container environment.

This helps to keep your container configuration secret. If you don't care all environment variables can be defined in **default.yaml** and everything will work fine.

Required and used for new ldap server only:
- **MATTERMOST_LDAP_REDIRECT_URI**: Mattermost oauth client redirect uri. Defaults to `http://mattermost.company.com:8065/signup/gitlab/complete`

- **MATTERMOST_LDAP_OAUTH_CLIENT_ID**: Mattermost oauth client id. Defaults to `` a random value will be generated.
- **MATTERMOST_LDAP_OAUTH_CLIENT_SECRET**: Mattermost oauth client secret. Defaults to `` a random value will be generated.
- **MATTERMOST_LDAP_OAUTH_GRANT_TYPE** Oauth grant type. Defaults to `authorization_code`
- **MATTERMOST_LDAP_OAUTH_SCOPE** Oauth scope. Defaults to `api`

- **MATTERMOST_LDAP_DATE_TIMEZONE** Timezone used for token timestamps. Defaults to `Europe/Paris`

Ldap
- **MATTERMOST_LDAP_LDAP_HOST** Ldap host. Defaults to `readonly`
- **MATTERMOST_LDAP_LDAP_PORT** Ldap port. Defaults to `389`
- **MATTERMOST_LDAP_LDAP_VERSION** Ldap protocol version. Defaults to `3`

- **MATTERMOST_LDAP_LDAP_BASE_DN** Ldap search base DN. Defaults to `ou=People,o=Company`
- **MATTERMOST_LDAP_LDAP_SEARCH_ATTRIBUTE** Login search attribute. Defaults to `uid`
- **MATTERMOST_LDAP_LDAP_FILTER** Ldap search filter: Defaults to `objectClass=*`
- **MATTERMOST_LDAP_LDAP_BIND_DN** DN for ldap search. Defaults to ``
- **MATTERMOST_LDAP_LDAP_BIND_PASSWORD** Ldap search dn password. Defaults to ``

Ldap TLS config (not used for now) 
- **MATTERMOST_LDAP_LDAP_CLIENT_TLS**: Enable ldap client tls config, ldap server certificate check and set client  certificate. Defaults to `false`
- **MATTERMOST_LDAP_LDAP_CLIENT_TLS_REQCERT**: Set ldap.conf TLS_REQCERT. Defaults to `demand`
- **MATTERMOST_LDAP_LDAP_CLIENT_TLS_CA_CRT_FILENAME**: Set ldap.conf TLS_CACERT to /container/service/ldap-client/assets/certs/$MATTERMOST_LDAP_LDAP_CLIENT_TLS_CA_CRT_FILENAME. Defaults to `ldap-ca.crt`
- **MATTERMOST_LDAP_LDAP_CLIENT_TLS_CRT_FILENAME**: Set .ldaprc TLS_CERT to /container/service/ldap-client/assets/certs/$MATTERMOST_LDAP_LDAP_CLIENT_TLS_CRT_FILENAME. Defaults to `ldap-client.crt`
- **MATTERMOST_LDAP_LDAP_CLIENT_TLS_KEY_FILENAME**: Set .ldaprc TLS_KEY to /container/service/ldap-client/assets/certs/$MATTERMOST_LDAP_LDAP_CLIENT_TLS_KEY_FILENAME. Defaults to `ldap-client.key`

Other environment variables:
- **MATTERMOST_LDAP_MARIADB_HOST**: Database host. Defaults to `mariadb.example.org`
- **MATTERMOST_LDAP_MARIADB_PORT**: Database port. Defaults to `3306`
- **MATTERMOST_LDAP_MARIADB_DATABASE**: Database name. Defaults to `mattermost-ldap`
- **MATTERMOST_LDAP_MARIADB_USER**: Database user. Defaults to `user`
- **MATTERMOST_LDAP_MARIADB_PASSWORD**: Database user password. Defaults to `password`

Database tls config (not used for now)
- **LDAP_CLIENT_SSL_HELPER_PREFIX**: Ldap client ssl-helper environment variables prefix. Defaults to `ldapclient`, ssl-helper first search config from LDAPCLIENT_SSL_HELPER_* variables, before SSL_HELPER_* variables.
- **MARIADB_CLIENT_SSL_HELPER_PREFIX**: Database ssl-helper environment variables prefix. Defaults to `database`, ssl-helper first search config from DATABASE_SSL_HELPER_* variables, before SSL_HELPER_* variables.

- **SSL_HELPER_AUTO_RENEW_SERVICES_IMPACTED**: Services that must be restarted after certificates renewal. Defaults to `:apache2 :php7.3-fpm`

### Set your own environment variables

#### Use command line argument
Environment variables can be set by adding the --env argument in the command line, for example:

	docker run --env LDAP_ORGANISATION="My company" --env LDAP_DOMAIN="my-company.com" \
	--env LDAP_ADMIN_PASSWORD="JonSn0w" --detach osixia/mattermost-ldap:1.0.0

Be aware that environment variable added in command line will be available at any time
in the container. In this example if someone manage to open a terminal in this container
he will be able to read the admin password in clear text from environment variables.

#### Link environment file

For example if your environment files **my-env.yaml** and **my-env.startup.yaml** are in /data/mattermost-ldap/environment

	docker run --volume /data/mattermost-ldap/environment:/container/environment/01-custom \
	--detach osixia/mattermost-ldap:1.0.0

Take care to link your environment files folder to `/container/environment/XX-somedir` (with XX < 99 so they will be processed before default environment files) and not  directly to `/container/environment` because this directory contains predefined baseimage environment files to fix container environment (INITRD, LANG, LANGUAGE and LC_CTYPE).

Note: the container will try to delete the **\*.startup.yaml** file after the end of startup files so the file will also be deleted on the docker host. To prevent that : use --volume /data/mattermost-ldap/environment:/container/environment/01-custom**:ro** or set all variables in **\*.yaml** file and don't use **\*.startup.yaml**:

	docker run --volume /data/mattermost-ldap/environment/my-env.yaml:/container/environment/01-custom/env.yaml \
	--detach osixia/mattermost-ldap:1.0.0

#### Make your own image or extend this image

This is the best solution if you have a private registry. Please refer to the [Advanced User Guide](#advanced-user-guide) just below.

## Advanced User Guide

### Extend osixia/mattermost-ldap:1.0.0 image

If you need to add your custom TLS certificate, bootstrap config or environment files the easiest way is to extends this image.

Dockerfile example:

	FROM osixia/mattermost-ldap:1.0.0

	ADD certs /container/service/mattermost-ldap/assets/apache2/certs
	ADD environment /container/environment/01-custom

See complete example in **example/extend-osixia-mattermost-ldap**

Warning: if you want to install new packages from debian repositories, this image has a configuration to prevent documentation and locales to be installed. If you need the doc and locales remove the following files :
**/etc/dpkg/dpkg.cfg.d/01_nodoc** and **/etc/dpkg/dpkg.cfg.d/01_nolocales**

### Make your own image

Clone this project:

	git clone https://github.com/osixia/docker-mattermost-ldap
	cd docker-mattermost-ldap

Adapt Makefile, set your image NAME and VERSION, for example:

	NAME = osixia/mattermost-ldap
	VERSION = 1.0.0

	become:
	NAME = cool-guy/mattermost-ldap
	VERSION = 1.0.0

Add your custom certificate, environment files...

Build your image:

	make build

Run your image:

	docker run --detach cool-guy/mattermost-ldap:1.0.0

### Tests

We use **Bats** (Bash Automated Testing System) to test this image:

> [https://github.com/bats-core/bats-core](https://github.com/bats-core/bats-core)

Install Bats, and in this project directory run:

	make test

### Kubernetes

Kubernetes is an open source system for managing containerized applications across multiple hosts, providing basic mechanisms for deployment, maintenance, and scaling of applications.

More information:
- http://kubernetes.io
- https://github.com/kubernetes/kubernetes

osixia/mattermost-ldap kubernetes examples are available in **example/kubernetes**

### Under the hood: osixia/light-baseimage

This image is based on osixia/light-baseimage.
It uses the following features:

- **ssl-tools** service to generate tls certificates
- **log-helper** tool to print log messages based on the log level
- **run** tool as entrypoint to init the container environment

To fully understand how this image works take a look at:
https://github.com/osixia/docker-light-baseimage

## Security
If you discover a security vulnerability within this docker image, please send an email to the Osixia! team at security@osixia.net. For minor vulnerabilities feel free to add an issue here on github.

Please include as many details as possible.

## Changelog

Please refer to: [CHANGELOG.md](CHANGELOG.md)

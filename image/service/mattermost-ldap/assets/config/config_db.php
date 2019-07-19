<?php

$db_port  	  = {{ MATTERMOST_LDAP_MARIADB_PORT }};
$db_host  	  = '{{ MATTERMOST_LDAP_MARIADB_HOST }}';
$db_name  	  = '{{ MATTERMOST_LDAP_MARIADB_DATABASE }}';
$db_type	  = 'mysql';
$db_user      = '{{ MATTERMOST_LDAP_MARIADB_USER }}';
$db_pass      = '{{ MATTERMOST_LDAP_MARIADB_PASSWORD }}';
$dsn	      = $db_type . ":dbname=" . $db_name . ";host=" . $db_host . ";port=" . $db_port; 

/* Uncomment the line below to set date.timezone to avoid E.Notice raise by strtotime() (in Pdo.php)
 * If date.timezone is not defined in php.ini or with this function, Mattermost could return a bad token request error
*/
date_default_timezone_set('{{ MATTERMOST_LDAP_DATE_TIMEZONE }}');

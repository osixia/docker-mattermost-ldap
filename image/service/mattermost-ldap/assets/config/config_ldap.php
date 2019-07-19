<?php
// LDAP parameters
$ldap_host = '{{ MATTERMOST_LDAP_LDAP_HOST }}';
$ldap_port = {{ MATTERMOST_LDAP_LDAP_PORT }};
$ldap_version = {{ MATTERMOST_LDAP_LDAP_VERSION }};

// Attribute use to identify user on LDAP - ex : uid, mail, sAMAccountName	
$ldap_search_attribute = '{{ MATTERMOST_LDAP_LDAP_SEARCH_ATTRIBUTE }}';

// variable use in resource.php 
$ldap_base_dn = '{{ MATTERMOST_LDAP_LDAP_BASE_DN }}';
$ldap_filter = '{{ MATTERMOST_LDAP_LDAP_FILTER }}';

// ldap service user to allow search in ldap
$ldap_bind_dn = '{{ MATTERMOST_LDAP_LDAP_BIND_DN }}';
$ldap_bind_pass = '{{ MATTERMOST_LDAP_LDAP_BIND_PASSWORD }}';

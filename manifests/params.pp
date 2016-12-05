# See README.md for details.
class openldap::params {
  $client_package = 'openldap2-client'
  $client_conffile = '/etc/openldap/ldap.conf'
  $server_confdir = '/etc/openldap/slapd.d'
  $server_conffile = '/etc/openldap/slapd.conf'
  $server_group = 'ldap'
  $server_owner = 'ldap'
  $server_package = 'openldap2'
  $server_service = 'slapd'
  $server_service_hasstatus = true
  $utils_package = 'openldap2-client'
}

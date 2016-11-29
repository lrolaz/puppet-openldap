class { 'openldap::server': }
openldap::server::schema { 'kerberos':
  ensure  => present,
  path    => '/usr/share/doc/packages/krb5/kerberos.schema',
}
openldap::server::database { 'dc=example,dc=com':
  directory => '/var/lib/ldap',
  rootdn    => 'cn=admin,dc=example,dc=com',
  rootpw    => 'secret',
  
}
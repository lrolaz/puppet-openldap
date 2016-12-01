class { 'openldap::server': 
  
}

openldap::server::access { '{0}to * by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage by * break':
  suffix  => 'olcDatabase={0}config,cn=config',
  
}

openldap::server::database { 'dc=foo,dc=example.com':
  ensure => present,
  rootdn    => 'cn=admin,dc=foo,dc=example.com',
  rootpw    => 'secret',  
}

package { 'krb5-plugin-kdb-ldap' :
  ensure  => installed,
} -> openldap::server::schema { 'kerberos':
  ensure  => present,
  path    => '/usr/share/doc/packages/krb5/kerberos.schema',
} -> openldap::server::schema { 'inetorgperson':
  ensure  => present,
  path    => '/etc/openldap/schema/inetorgperson.schema',
}



class { 'openldap::server': 
  
}

openldap::server::database { 'dc=pictet,dc=com':
  ensure => present,
  rootdn    => 'cn=admin,dc=pictet,dc=com',
  rootpw    => 'secret',  
}

openldap::server::schema { 'core':
  ensure  => present,
  path    => '/etc/openldap/schema/core.schema',
} -> openldap::server::schema { 'cosine':
  ensure  => present,
  path    => '/etc/openldap/schema/cosine.schema',
} -> openldap::server::schema { 'rfc2307bis':
  ensure  => present,
  path    => '/etc/openldap/schema/rfc2307bis.schema',
} -> openldap::server::schema { 'inetorgperson':
  ensure  => present,
  path    => '/etc/openldap/schema/inetorgperson.schema',
}

openldap::server::access { '3 on dc=pictet,dc=com':
  what     => 'dn.subtree="cn=PICTET.COM,cn=krbcontainer,dc=pictet,dc=com"',
  access   => [
    'by dn.exact="cn=admin,dc=pictet,dc=com" read',
    'by dn.exact="cn=admin,dc=pictet,dc=com" write',
    'by * none',
  ],
}

package { 'krb5-server' :
  ensure  => installed, 
}
package { 'krb5-client' :
  ensure  => installed, 
}
package { 'krb5-plugin-kdb-ldap' :
  ensure  => installed, 
} -> openldap::server::schema { 'kerberos':
  ensure  => present,
  path    => '/usr/share/doc/packages/krb5/kerberos.schema',
} -> file { '/etc/krb5.conf':
  ensure  => file,
  content => '[libdefaults]
  default_realm = PICTET.COM 

[realms]
  EXAMPLE.COM = {
          kdc = openldap.example.com
    admin_server = openldap.example.com
                default_domain =   pictet.com
                database_module = openldap_ldapconf
  }

[dbdefaults]
        ldap_kerberos_container_dn = dc=pictet,dc=com

[dbmodules]
        openldap_ldapconf = {
                db_library = kldap

                ldap_kdc_dn = "cn=admin,dc=pictet,dc=com"
                # this object needs to have read rights on
                # the realm container, principal container and realm sub-trees

                ldap_kadmind_dn = "cn=admin,dc=pictet,dc=com"
                # this object needs to have read and write rights on
                # the realm container, principal container and realm sub-trees

                ldap_service_password_file = /etc/krb5kdc/service.keyfile
                ldap_servers = ldapi:/// ldap://
                ldap_conns_per_server = 5
        }

[dbdefaults]
        ldap_kerberos_container_dn = cn=krbContainer,dc=pictet,dc=com

[logging]
    kdc = FILE:/var/log/krb5/krb5kdc.log
    admin_server = FILE:/var/log/krb5/kadmind.log
    default = SYSLOG:NOTICE:DAEMON'
}

 


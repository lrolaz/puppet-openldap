class { 'openldap::server': 
  
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
} -> openldap::server::schema { 'samba3':
  ensure  => present,
  path    => '/etc/openldap/schema/samba3.schema',   
} -> openldap::server::database { 'dc=pictet,dc=com':
  ensure => present,
  rootdn    => 'cn=admin,dc=pictet,dc=com',
  rootpw    => 'secret',   
} -> openldap::server::entry{ "ou people":
  dn => "ou=people,dc=pictet,dc=com",
  attributes => [ 
    "ou: people",
    "objectClass: organizationalUnit" ],
  unique_attributes => ["ou"],
  ensure => present,
}

 
 package { 'krb5-server' :
  ensure  => installed, 
} -> package { 'krb5-client' :
  ensure  => installed, 
} -> package { 'krb5-plugin-kdb-ldap' :
  ensure  => installed, 
} -> openldap::server::schema { 'kerberos':
  ensure  => present,
  path    => '/usr/share/doc/packages/krb5/kerberos.schema',   
} -> openldap::server::access { '4 on dc=pictet,dc=com':
  what     => 'attrs=krbPrincipalKey',
  access   => [
    'by dn="cn=admin,dc=pictet,dc=com" write',
    'by self write',
    'by anonymous auth',
    'by * none',
  ],  
} -> file { '/etc/krb5.conf':
  ensure  => file,
  content => '[libdefaults]
  default_realm = PICTET.COM 
  default_ccache_name = /tmp/krb5cc_%{uid} 

[realms]
  PICTET.COM = {
          kdc = openldap.example.com
    admin_server = openldap.example.com
                default_domain =   pictet.com
                database_module = openldap_ldapconf
  }

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
-> exec { "Create Kerberos Realm" :
  command => '/usr/lib/mit/sbin/kdb5_ldap_util -D cn=admin,dc=pictet,dc=com -w secret -P secret create -r PICTET.COM -s -H ldap://',
  unless => '/usr/bin/ldapsearch -b cn=PICTET.COM,cn=krbContainer,dc=pictet,dc=com -H ldapi:///',
} -> file { '/etc/krb5kdc':
  ensure  => directory,
} -> file { '/etc/krb5kdc/service.keyfile':
  ensure  => file,
  mode    => 700,
  content => 'cn=admin,dc=pictet,dc=com#{HEX}736563726574',
} -> service { 'krb5kdc.service' :
  ensure => running,
  enable => true,
} -> openldap::server::module { 'smbkrb5pwd':
  ensure  => present,    
} -> openldap::server::overlay { 'smbkrb5pwd on dc=pictet,dc=com':
  ensure  => present,
  options => {
   "olcSmbKrb5PwdMustChange" => "2592012",
   "olcSmbKrb5PwdEnable" => "krb5",
   "olcSmbKrb5PwdKrb5Realm" => "PICTET.COM", 
  },    
} -> openldap::server::entry{"user01":
  dn => "cn=user01,ou=people,dc=pictet,dc=com",
  attributes => [ 
    "cn: user01",
    "sn: user01",
    "uid: user01",
    "objectClass: inetOrgPerson",
    "displayName: User01", 
  ],
    
  unique_attributes => ["cn"],    
  ensure => present,
} -> exec { "/usr/lib/mit/sbin/kadmin.local -q 'addprinc -pw secret user01'" :
  unless => "/usr/lib/mit/sbin/kadmin.local -q 'get_principal user01' | /usr/bin/grep 'Principal: user01'",
}


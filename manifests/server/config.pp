# See README.md for details.
class openldap::server::config {
  if !defined(Class['openldap::server']) {
    fail 'class ::openldap::server has not been evaluated'
  }

  file_line { "openldap-ldapi":
    path  => "/etc/sysconfig/openldap",
    line  => 'OPENLDAP_START_LDAPI="yes"',
    match => "^OPENLDAP_START_LDAPI",
  }

  file { $::openldap::server::conffile:
    ensure  => file,
    owner   => $::openldap::server::owner,
    group   => $::openldap::server::group,
    mode    => '0640',
    content => '',
  } -> file { $::openldap::server::confdir:
    ensure => directory,
    owner  => $::openldap::server::owner,
    group  => $::openldap::server::group,
    mode   => '0750',
    force  => true,
  }

  file_line { "openldap-backend":
    path  => "/etc/sysconfig/openldap",
    line  => 'OPENLDAP_CONFIG_BACKEND="ldap"',
    match => "^OPENLDAP_CONFIG_BACKEND",
  }
  exec { "/usr/sbin/slaptest -f /etc/openldap/slapd.conf -F /etc/openldap/slapd.d":
    user    => $::openldap::server::owner,
    creates => "${::openldap::server::confdir}/cn=config"
  } -> file_line { "olcRootDN-config":
    path  => "${::openldap::server::confdir}/cn=config/olcDatabase={0}config.ldif",
    line  => "olcRootDN: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth",
    match => "olcRootDN:.*",
  } -> file_line { "olcRootDN-CRC":
    path  => "${::openldap::server::confdir}/cn=config/olcDatabase={0}config.ldif",
    line  => "# Disable CRC",
    match => "# CRC",
  }

}

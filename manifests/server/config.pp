# See README.md for details.
class openldap::server::config {

  if ! defined(Class['openldap::server']) {
    fail 'class ::openldap::server has not been evaluated'
  }

  $slapd_ldap_ifs = empty($::openldap::server::ldap_ifs) ? {
    false => join(prefix($::openldap::server::ldap_ifs, 'ldap://'), ' '),
    true  => '',
  }
  $slapd_ldapi_ifs = empty($::openldap::server::ldapi_ifs) ? {
    false => join(prefix($::openldap::server::ldapi_ifs, 'ldapi://'), ' '),
    true  => '',
  }
  $slapd_ldaps_ifs = empty($::openldap::server::ldaps_ifs) ? {
    false  => join(prefix($::openldap::server::ldaps_ifs, 'ldaps://'), ' '),
    true => '',
  }
  $slapd_ldap_urls = "${slapd_ldap_ifs} ${slapd_ldapi_ifs} ${slapd_ldaps_ifs}"

  case $::osfamily {
    'Debian': {
      shellvar { 'slapd':
        ensure   => present,
        target   => '/etc/default/slapd',
        variable => 'SLAPD_SERVICES',
        value    => $slapd_ldap_urls,
      }
    }
    'RedHat': {
      if versioncmp($::operatingsystemmajrelease, '6') <= 0 {
        $ldap = empty($::openldap::server::ldap_ifs) ? {
          false => 'yes',
          true  => 'no',
        }
        shellvar { 'SLAPD_LDAP':
          ensure   => present,
          target   => '/etc/sysconfig/ldap',
          variable => 'SLAPD_LDAP',
          value    => $ldap,
        }
        $ldaps = empty($::openldap::server::ldaps_ifs) ? {
          false => 'yes',
          true  => 'no',
        }
        shellvar { 'SLAPD_LDAPS':
          ensure   => present,
          target   => '/etc/sysconfig/ldap',
          variable => 'SLAPD_LDAPS',
          value    => $ldaps,
        }
        $ldapi = empty($::openldap::server::ldapi_ifs) ? {
          false => 'yes',
          true  => 'no',
        }
        shellvar { 'SLAPD_LDAPI':
          ensure   => present,
          target   => '/etc/sysconfig/ldap',
          variable => 'SLAPD_LDAPI',
          value    => $ldapi,
        }
      } else {
        shellvar { 'slapd':
          ensure   => present,
          target   => '/etc/sysconfig/slapd',
          variable => 'SLAPD_URLS',
          value    => $slapd_ldap_urls,
        }
      }
    }
  'Suse': {
      shellvar { 'openldap-ldapi':
        ensure   => present,
        target   => '/etc/sysconfig/openldap',
        variable => 'OPENLDAP_START_LDAPI',
        value    => empty($::openldap::server::ldapi_ifs) ? {
          false => 'yes',
          true  => 'no',    
        }
      }
      case $::openldap::server::provider {
      'augeas': {
        file { $::openldap::server::conffile:
          ensure  => file,
          owner   => $::openldap::server::owner,
          group   => $::openldap::server::group,
          mode    => '0640',
        }
      }
      'olc': {
        file { $::openldap::server::conffile:
          ensure  => file,
          owner   => $::openldap::server::owner,
          group   => $::openldap::server::group,
          mode    => '0640',
          content => '',
        } -> file { $::openldap::server::confdir:
          ensure  => directory,
          owner   => $::openldap::server::owner,
          group   => $::openldap::server::group,
          mode    => '0750',
          force   => true,
        }
	      shellvar { 'openldap-backend':
	        ensure   => present,
	        target   => '/etc/sysconfig/openldap',
	        variable => 'OPENLDAP_CONFIG_BACKEND',
	        value    => 'ldap',
	      }
	      exec { "/usr/sbin/slaptest -f /etc/openldap/slapd.conf -F /etc/openldap/slapd.d" :
	        user    => $::openldap::server::owner,
	        creates => "${::openldap::server::confdir}/cn=config"
	      } -> file_line  { "olcRootDN-config" :
	        path     => "${::openldap::server::confdir}/cn=config/olcDatabase={0}config.ldif",
          line     => "olcRootDN: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth",
          match    => "olcRootDN:.*", 
        }
	    }
	    default: {
        fail 'provider must be one of "olc" or "augeas"'
      }
	    }
    }
    default: {
      fail "Operating System Family ${::osfamily} not yet supported"
    }
 } 
}

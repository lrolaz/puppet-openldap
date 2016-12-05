# See README.md for details.
class openldap::server::install {

  if ! defined(Class['openldap::server']) {
    fail 'class ::openldap::server has not been evaluated'
  }

  contain ::openldap::utils

  package { $::openldap::server::package:
    ensure       => present,
  }
}

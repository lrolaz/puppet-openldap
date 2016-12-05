# See README.md for details.
class openldap::server (
  $package           = $openldap::params::server_package,
  $confdir           = $openldap::params::server_confdir,
  $conffile          = $openldap::params::server_conffile,
  $service           = $openldap::params::server_service,
  $service_hasstatus = $openldap::params::server_service_hasstatus,
  $owner             = $openldap::params::server_owner,
  $group             = $openldap::params::server_group,
  $enable            = true,
  $start             = true,
  $provider          = 'olc',
  $ssl_key           = undef,
  $ssl_cert          = undef,
  $ssl_ca            = undef,
  $databases         = {
  }
  ,) inherits ::openldap::params {
  validate_hash($databases)

  class { '::openldap::server::install': } ->
  class { '::openldap::server::config': } ~>
  class { '::openldap::server::service': }

  class { '::openldap::server::slapdconf': }

  Class['openldap::server::service'] ->
  Class['openldap::server::slapdconf'] ->
  Class['openldap::server']

}

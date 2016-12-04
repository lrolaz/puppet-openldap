# See README.md for details.
define openldap::server::entry(
  $ensure            = undef,
  $dn                = undef,
  $attributes        = undef,
  $unique_attributes = undef,
) {

  if ! defined(Class['openldap::server']) {
    fail 'class ::openldap::server has not been evaluated'
  }

  Class['openldap::server::service'] ->
  Openldap::Server::Entry[$title] ->
  Class['openldap::server']

  openldap_entry { $title:
    ensure            => $ensure,
    dn                => $dn,
    attributes        => $attributes,
    unique_attributes => $unique_attributes,    
  }
}

class vps::cron (
){

  package { 'cronie':
    ensure => installed,
  } ->

  service { 'crond':
    ensure => running,
  }
}

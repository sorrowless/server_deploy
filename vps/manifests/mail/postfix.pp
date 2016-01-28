class vps::mail::postfix (
  $myorigin,
  $package_ensure = 'present',
  $service_ensure = 'running',
  $helo_regexp = undef,
  $recipient_regexp = undef,
  $virtual_reroute = undef,
  $mailcert = false,
  $mailkey = false,
){

  package { 'postfix':
    ensure => $package_ensure,
  } ->

  file { '/etc/postfix/main.cf':
    ensure => present,
    content => template('vps/postfix/main.cf.erb'),
  } ->

  file { '/etc/postfix/master.cf':
    ensure => present,
    content => template('vps/postfix/master.cf'),
  } ->

  file { '/etc/postfix/helo_regexp':
    ensure => present,
    content => template('vps/postfix/helo_regexp.erb'),
  } ->

  file { '/etc/postfix/recipient_access':
    ensure => present,
    content => template('vps/postfix/recipient_access.erb'),
  } ->

  file { '/etc/postfix/virtual':
    ensure => present,
    content => template('vps/postfix/virtual.erb'),
  } ->

  file { '/etc/postfix/header_checks.pcre':
    ensure => present,
    content => template('vps/postfix/header_checks.pcre'),
  }

  if $mailcert {
    file { '/etc/postfix/keys':
      ensure => directory,
      before => File['/etc/postfix/keys/mailcert.pem', '/etc/postfix/keys/mailkey.pem'],
    }

    file { '/etc/postfix/keys/mailcert.pem':
      ensure => present,
      content => $mailcert,
    }

    file { '/etc/postfix/keys/mailkey.pem':
      ensure => present,
      content => $mailkey,
    }
  }

  File <||> ~> Service<| title == 'postfix'|>

  service { 'postfix':
    ensure => $service_ensure,
    enable => true,
  }
}

class vps::mail::spamassassin (
){

  package { ['spamassassin']:
    ensure => 'present',
  } ->

  file { '/etc/mail/spamassassin/local.cf':
    ensure => present,
    content => template('vps/spamassassin/local.cf.erb')
  } ->

  file { '/usr/share/spamassassin/99_wentor.cf':
    ensure => present,
    content => template('vps/spamassassin/99_wentor.cf.erb')
  } ~>

  service { 'spamassassin':
    ensure => 'running',
    enable => true,
  }
}

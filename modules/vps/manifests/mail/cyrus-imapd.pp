class vps::mail::cyrus-imapd (
  $cyrus_admin,
  $loginrealms,
  $package_ensure = 'present',
  $service_ensure = 'running',
){

  package { ['cyrus-imapd', 'cyrus-sasl', 'cyrus-sasl-plain', 'cyrus-sasl-md5']:
    ensure => $package_ensure,
  }
 
  Package<| title == 'cyrus-imapd' |> -> File <||>
  Package<| title == 'cyrus-sasl' |> -> File <||>
 
  file { '/etc/cyrus.conf':
    ensure => present,
    content => template('vps/cyrus-imapd/cyrus.conf')
  } 
 
  file { '/etc/imapd.conf':
    ensure => present,
    content => template('vps/cyrus-imapd/imapd.conf.erb')
  } 
 
  file { '/etc/sasl2/smtpd.conf':
    ensure => present,
    content => template('vps/cyrus-imapd/sasl2/smtpd.conf')
  } 
 
  file { '/etc/sasl2/Sendmail.conf':
    ensure => present,
    content => template('vps/cyrus-imapd/sasl2/Sendmail.conf')
  } 

  File <||> -> Service <| title == 'saslsuthd' |>
  File <||> -> Service <| title == 'cyrus-imapd' |>

  service { ['saslauthd', 'cyrus-imapd']:
    ensure => $service_ensure,
    enable => true,
  }
}

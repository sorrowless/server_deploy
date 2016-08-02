class vps::iptables (
  $vpn_network,
  $internal_interface,
  $external_interface,
  $sshd_port,
  $openvpn_port,
){

  if $operatingsystem == 'CentOS' and $operatingsystemmajrelease == 7 {
    package { 'iptables-services':
      ensure => present,
    }

    Package['iptables-services'] -> Service['iptables']
  }

  file { '/etc/sysconfig/iptables':
  ensure => present,
  content => template('vps/iptables.erb'),
  notify => Service['iptables'],
  }

  service { 'iptables':
    ensure => running,
    enable => true,
  }
}

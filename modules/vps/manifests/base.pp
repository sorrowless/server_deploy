include vps::users

if $::operatingsystem == 'CentOS' {
  package { 'epel-release':
    ensure => present,
  }
}

$packages = [ 'vim-common', 'rsync', 'mc', 'git' ]
package { $packages:
  ensure => present,
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

$sshd_port = hiera('sshd_port')
$admin_user = hiera('admin_user')
file { '/etc/ssh/sshd_config':
  ensure => present,
  content => template('vps/sshd_config.erb'),
  notify => Service['sshd'],
}

service { 'sshd':
  ensure => running,
  enable => true,
}

$authorized_keys = hiera('authorized_keys')
file { "/home/${admin_user}/.ssh":
  ensure => directory,
  owner => $admin_user,
  group => $admin_user,
} ->

file { "/home/${admin_user}/.ssh/authorized_keys":
  ensure => present,
  owner => $admin_user,
  group => $admin_user,
  mode => '0600',
  content => template('vps/authorized_keys.erb'),
}

# install and configure postfix
$helo_regexp = hiera('postfix_helo_regexp', {})
class { 'vps::mail::postfix':
  myorigin => hiera('postfix_myorigin'),
  helo_regexp => $helo_regexp, 
  recipient_regexp => hiera('postfix_recipient_access'),
  virtual_reroute => hiera('postfix_virtual_rewrite'),
  mailcert => hiera('postfix_pemcert'),
  mailkey => hiera('postfix_pemkey'),
}


# install and configure cyrus-imapd
class { 'vps::mail::cyrus-imapd':
  cyrus_admin => hiera('cyrus_admin'),
  loginrealms => hiera('cyrus_loginrealms'),
}


$acme = hiera('use_letsencrypt', false)
# install and configure nginx and all nginx sites
class { 'vps::nginx':
  domain => hiera('nginx_domain'),
  ssl_data => hiera('nginx_ssl'),
  acme => acme,
}

if $acme {
  class { 'vps::letsencrypt':
    ssl_data => hiera('nginx_ssl'),
  }
}


# install and configure mysql
class { 'vps::mysql': }


# configure sysctl
class { 'vps::sysctl': }

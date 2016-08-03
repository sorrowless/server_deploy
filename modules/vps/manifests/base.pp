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

# Start defining local variables

$vpn_network = hiera('vpn_network')
$internal_interface = hiera('internal_interface')
$external_interface = hiera('external_interface')
$openvpn_port = hiera('openvpn_port')
$sshd_port = hiera('sshd_port')

$admin_user = hiera('admin_user')

$acme = hiera('use_letsencrypt', false)

# End defining local variables

# Setup iptables
class { 'vps::iptables':
  vpn_network => $vpn_network,
  internal_interface => $internal_interface,
  external_interface => $external_interface,
  sshd_port => $sshd_port,
  openvpn_port => $openvpn_port,
}

# Setup sshd and keys for it
class { 'vps::ssh':
  sshd_port => $sshd_port,
}


# Install and configure postfix
class { 'vps::mail::postfix':
  myorigin => hiera('postfix_myorigin'),
  helo_regexp => hiera('postfix_helo_regexp', {}),
  recipient_regexp => hiera('postfix_recipient_access'),
  virtual_reroute => hiera('postfix_virtual_rewrite'),
  mailcert => hiera('postfix_pemcert'),
  mailkey => hiera('postfix_pemkey'),
}


# Install and configure cyrus-imapd
class { 'vps::mail::cyrus-imapd':
  cyrus_admin => hiera('cyrus_admin'),
  loginrealms => hiera('cyrus_loginrealms'),
}

class { 'vps::mail::spamassassin': }


# Install and configure nginx and all nginx sites
class { 'vps::nginx::nginx':
  domain => hiera('nginx_domain'),
  ssl_data => hiera('nginx_ssl'),
  acme => acme,
}


# install and configure mysql
class { 'vps::mysql': }


# configure sysctl
class { 'vps::sysctl': }


# configure openvpn
class { 'vps::openvpn':
  servername => $admin_user,
}


# install and configure cron
class { 'vps::cron': }


# configure backup
$mysql_password = hiera('mysql_password')
$backup_authorized_keys = hiera('backup_authorized_keys')
class { 'vps::backup':
  mysql_password => $mysql_password,
  auth_keys => $backup_authorized_keys,
}

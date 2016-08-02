class vps::ssh (
  $sshd_port = 22,
){
    $admin_user = hiera('admin_user')
    $authorized_keys = hiera('authorized_keys')

    file { '/etc/ssh/sshd_config':
      ensure => present,
      content => template('vps/sshd_config.erb'),
      notify => Service['sshd'],
    }

    service { 'sshd':
      ensure => running,
      enable => true,
    }

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
}
class vps::backup (
  $mysql_password,
  $auth_keys,
){

  file { '/root/backup.sh':
    ensure => present,
    content => template('vps/backup.sh.erb'),
    owner => root,
    group => root,
    mode => '0750',
  }

  file { '/root/restore.sh':
    ensure => present,
    content => template('vps/restore.sh.erb'),
    owner => root,
    group => root,
    mode => '0750',
  }

  cron { "backup data":
    command => "/root/backup.sh",
    minute => '1',
    hour => '0',
    monthday => '*',
    month => '*',
  }

  file { ['/backup','/backup/mysql','/backup/git','/backup/www/','/backup/configs/']:
    ensure => directory,
  }

  #TODO(sbog): rework this ASAP
  file { '/home/backup/.ssh':
    ensure => directory,
    owner => 'backup',
    group => 'backup',
  } ->

  file { "/home/backup/.ssh/authorized_keys":
    ensure => present,
    owner => 'backup',
    group => 'backup',
    mode => '0600',
    content => template('vps/backup_authorized_keys.erb'),
  }

}

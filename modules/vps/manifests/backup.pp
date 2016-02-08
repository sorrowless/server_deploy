class vps::backup (
  $mysql_password,
){

  file { '/root/backup.sh':
    ensure => present,
    content => template('vps/backup.sh.erb'),
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
}

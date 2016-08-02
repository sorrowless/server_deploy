class vps::mysql (
  $ensure_package = 'present',
  $ensure_service = 'running',
){
  if $operatingsystem == 'CentOS' and $operatingsystemmajrelease == 7 {
    $mysql_packages = ['mariadb', 'mariadb-server']
    $mysql_service = 'mariadb'
    $mysql_logfile = '/var/log/mariadb/mariadb.log'
  } else {
    $mysql_packages = ['mysql', 'mysql-server']
    $mysql_service = 'mysqld'
    $mysql_logfile = '/var/log/mysqld.log'
  }

  package { $mysql_packages:
    ensure => $ensure_package,
    before => Service[$mysql_service],
  }

  file { '/etc/my.cnf':
    ensure => present,
    content => template('vps/mysql/my.cnf.erb'),
    notify => Service[$mysql_service],
  }

  service { $mysql_service:
    ensure => $ensure_service,
    enable => true,
  }

}

class vps::mysql (
  $ensure_package = 'present',
  $ensure_service = 'running',
){

  package { ['mysql', 'mysql-server']:
    ensure => $ensure_package,
    before => Service['mysqld'],
  }

  file { '/etc/my.cnf':
    ensure => present,
    content => template('vps/mysql/my.cnf'),
    notify => Service['mysqld'],
  }

  service { 'mysqld':
    ensure => $ensure_service,
    enable => true,
  }

}

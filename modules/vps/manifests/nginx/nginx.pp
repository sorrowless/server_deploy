class vps::nginx::nginx(
  $domain,
  $ssl_data = undef,
  $ensure_package = 'present',
  $ensure_service = 'running',
  $acme = false,
){

  # we need php and php-xml for mail system, php-mbstring and php-mysql for rss
  package { ['nginx', 'php-fpm', 'php', 'php-xml', 'php-mbstring', 'php-mysql', 'php-process', 'uwsgi', 'mysql-connector-python', 'gcc', 'python34-devel']:
    ensure => $ensure_package,
  } ->

  file { '/etc/nginx/ssl':
    ensure => directory,
  }

  File <| title == '/etc/nginx/ssl' |> -> Exec['create dhparam']
  Vps::Nginx::Config <||> -> Service['nginx','php-fpm']

  file { '/etc/nginx/nginx.conf':
    ensure => present,
    content => template('vps/http/nginx.conf'),
  }

  file { "/etc/nginx/conf.d/blog.${domain}.conf":
    ensure => present,
    content => template('vps/http/blog.conf.erb'),
  }

  vps::nginx::config { "dav.${domain}": short_name => "dav" }
  vps::nginx::config { "mail.${domain}": short_name => "mail" }
  vps::nginx::config { "rss.${domain}": short_name => "rss" }
  vps::nginx::config { "www.${domain}": short_name => "www" }
  vps::nginx::config { "beardlylion": short_name => "beardlylion" }


  file { "/etc/init.d/ttrss-daemon":
    ensure => present,
    content => template('vps/http/ttrss-daemon'),
    mode => '0755',
    owner => 'root',
    group => 'root',
  } ->

  service { 'ttrss-daemon':
    ensure => running,
    enable => true,
  }

  file { "/etc/uwsgi.ini":
    ensure => present,
    content => template('vps/http/uwsgi.ini.erb'),
  }

  file { "/etc/uwsgi.d/finland.ini":
    ensure => present,
    content => template('vps/http/uwsgi.finland.ini.erb'),
    require => Package['uwsgi'],
  }

  file { "/etc/php-fpm.d/www.conf":
    ensure => present,
    content => template('vps/http/php-fpm.conf'),
    require => Package['php-fpm'],
  }

  exec { 'create dhparam':
    path => '/bin:/usr/bin:/usr/sbin',
    command => 'openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048',
    creates => '/etc/nginx/ssl/dhparam.pem',
  }

  service { ['nginx', 'php-fpm']:
    ensure => $ensure_service,
    enable => true,
  }
  
}

class vps::nginx (
  $domain,
  $ssl_data = undef,
  $ensure_package = 'present',
  $ensure_service = 'running',
  $acme = false,
){
  
  # we need php and php-xml for mail system, php-mbstring and php-mysql for rss
  package { ['nginx', 'php-fpm', 'php', 'php-xml', 'php-mbstring', 'php-mysql', 'php-process']:
    ensure => $ensure_package,
  } ->

  file { '/etc/nginx/ssl':
    ensure => directory,
  }

  Package <| title == 'nginx' |> -> File<||> -> Service['nginx','php-fpm']

  file { '/etc/nginx/nginx.conf':
    ensure => present,
    content => template('vps/http/nginx.conf'),
  }

  file { "/etc/nginx/conf.d/blog.${domain}.conf":
    ensure => present,
    content => template('vps/http/blog.conf.erb'),
  }


  file { "/etc/nginx/conf.d/dav.${domain}.conf":
    ensure => present,
    content => template('vps/http/dav.conf.erb'),
  }
  
  file { "/etc/nginx/ssl/dav.${domain}.crt":
    ensure => present,
    content => $ssl_data['dav_cert'],
  }
  
  file { "/etc/nginx/ssl/dav.${domain}.key":
    ensure => present,
    content => $ssl_data['dav_key'],
  }


  file { "/etc/nginx/conf.d/mail.${domain}.conf":
    ensure => present,
    content => template('vps/http/mail.conf.erb'),
  }


  file { "/etc/nginx/conf.d/rss.${domain}.conf":
    ensure => present,
    content => template('vps/http/rss.conf.erb'),
  }
  
  file { "/etc/nginx/ssl/rss.${domain}.key":
    ensure => present,
    content => $ssl_data['rss_key'],
  }
  
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


  file { "/etc/nginx/conf.d/www.${domain}.conf":
    ensure => present,
    content => template('vps/http/www.conf.erb'),
  }

  file { "/etc/nginx/ssl/www.${domain}.crt":
    ensure => present,
    content => $ssl_data['www_cert'],
  }
  
  file { "/etc/nginx/ssl/www.${domain}.key":
    ensure => present,
    content => $ssl_data['www_key'],
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

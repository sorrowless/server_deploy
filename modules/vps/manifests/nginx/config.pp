define vps::nginx::config (
  $short_name,
  $ssl_data = hiera('nginx_ssl'),
){
    if ! defined(File["/etc/nginx/ssl/temp.crt"]) {
        file { "/etc/nginx/ssl/temp.crt":
            ensure => present,
            content => $ssl_data['temp_cert'],
        }
    }

    if ! defined(File["/etc/nginx/ssl/temp.key"]) {
        file { "/etc/nginx/ssl/temp.key":
            ensure => present,
            content => $ssl_data['temp_key'],
        }
    }
    file { "/etc/nginx/conf.d/${name}.conf":
        ensure => present,
        content => template("vps/http/${short_name}.conf.erb"),
    }

    file { "temp ${name}.key":
        path   => "/etc/nginx/ssl/${name}.key",
        ensure => link,
        target => "/etc/nginx/ssl/temp.key",
    }

    file { "temp ${name}.crt":
        path   => "/etc/nginx/ssl/${name}.crt",
        ensure => link,
        target => "/etc/nginx/ssl/temp.crt",
    }
}
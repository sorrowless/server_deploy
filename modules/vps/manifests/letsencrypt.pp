class vps::letsencrypt (
  $acme = false,
  $ssl_data = undef,
){

  file { '/var/www/html/challenges':
    ensure => directory,
  }
  
  file { "/etc/nginx/ssl/rss.${domain}.csr":
    ensure => present,
    content => $ssl_data['rss_csr'],
  }
  
  file { "/root/le_account.key":
    ensure => present,
    content => hiera('le_accountkey'),
  }
  
}

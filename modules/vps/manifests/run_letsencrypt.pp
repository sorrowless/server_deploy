class { 'vps::letsencrypt::letsencrypt':
  domain => hiera('nginx_domain'),
  ssl_data => hiera('nginx_ssl'),
}
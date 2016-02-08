class vps::letsencrypt (
  $domain,
  $ssl_data = undef,
){

  file { '/var/www/html/challenges':
    ensure => directory,
  }

  $rssbase_path = '/etc/nginx/ssl/rss'
  $rsscsr_path = "${rssbase_path}.${domain}.csr"
  file { $rsscsr_path:
    ensure => present,
    content => $ssl_data['rss_csr'],
  }

  $account_path = '/root/le_account.key'
  file { $account_path:
    ensure => present,
    content => hiera('le_accountkey'),
  }

  $letsencrypt_path = '/root/letsencrypt_client'
  vcsrepo { $letsencrypt_path:
    ensure => present,
    provider => git,
    source => 'https://github.com/sorrowless/acme-tiny.git',
  }

  cron { "regenerate rss.${domain} certificate":
    command => "python ${letsencrypt_path}/acme_tiny.py --account-key ${account_path} --csr ${rsscsr_path} --acme-dir /var/www/html/challenges/ > ${rssbase_path}.${domain}.crt && service nginx reload",
    minute => '1',
    hour => '0',
    monthday => '1',
    month => '*',
  }

}

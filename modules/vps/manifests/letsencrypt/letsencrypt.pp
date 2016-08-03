class vps::letsencrypt::letsencrypt (
  $domain,
  $ssl_data = undef,
  $out_path = "/etc/nginx/ssl/",
){

  file { '/var/www/html/challenges':
    ensure => directory,
  }

  vps::letsencrypt::lehost { "beardlylion":
    csr      => $ssl_data['beardlylion_csr'],
    out_path => $out_path,
  }

  vps::letsencrypt::lehost { "dav.${domain}":
    csr      => $ssl_data['dav_csr'],
    out_path => $out_path,
  }

  vps::letsencrypt::lehost { "mail.${domain}":
    csr      => $ssl_data['mail_csr'],
    out_path => $out_path,
  }

  vps::letsencrypt::lehost { "rss.${domain}":
    csr      => $ssl_data['rss_csr'],
    out_path => $out_path,
  }

  vps::letsencrypt::lehost { "www.${domain}":
    csr      => $ssl_data['www_csr'],
    out_path => $out_path,
  }
}

define vps::letsencrypt::lehost (
  $csr,
  $out_path,
  $account_key = '/root/le_account.key',
  $acme_dir = '/var/www/html/challenges/',
  $add_to_cron = true,
  $export_key = true,
  $key = "",
){

  $letsencrypt_path = '/root/letsencrypt_client'
  if ! defined (Vcsrepo[$letsencrypt_path]) {
      vcsrepo { $letsencrypt_path:
        ensure => present,
        provider => git,
        source => 'https://github.com/sorrowless/acme-tiny.git',
      }
  }

  if ! defined (File[$account_key]) {
      file { $account_key:
        ensure => present,
        content => hiera('le_accountkey'),
      }
  }

  $csr_path = "${out_path}/${name}.csr"
  file { $csr_path:
    ensure => present,
    content => $csr,
  }

  File <| title == $csr_path |> -> Exec["${name}.crt"]

  exec { "${name}.crt":
    command => "python ${letsencrypt_path}/acme_tiny.py --account-key ${account_key} --csr ${csr_path} --acme-dir ${acme_dir} > ${out_path}/${name}.crt",
    path    => "/bin:/usr/bin"
  }

  if $add_to_cron {
      cron { "regenerate ${name} certificate":
        command => "python ${letsencrypt_path}/acme_tiny.py --account-key ${account_key} --csr ${csr_path} --acme-dir ${acme_dir} > ${out_path}/${name}.crt",
        minute => '1',
        hour => '0',
        monthday => '1',
        month => '*',
      }
  }

  if $export_key {
      file { "${out_path}/${name}.key":
        ensure => file,
        content => $key,
      }
  }
}
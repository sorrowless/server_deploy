class vps::users (
  $exists = true,
){
  $ensure = $exists ? {
    true => 'present',
    false => 'absent',
  }

  $admin = hiera('admin_user')
  user { $admin:
    ensure => $ensure,
    password => hiera('admin_password'),
    managehome => true,
  }

  user { 'git':
    ensure => $ensure,
    managehome => true,
    home => '/home/git/',
    shell => '/bin/bash',
  }

  user { 'backup':
    ensure => $ensure,
    managehome => true,
    home => '/home/backup/',
    shell => '/bin/bash',
  } -> File <| title == '/home/backup/.ssh' |>
}

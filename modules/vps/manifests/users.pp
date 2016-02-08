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
    uid => 1000,
    gid => 1000,
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

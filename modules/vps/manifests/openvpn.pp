class vps::openvpn (
  $servername,
){
  $server = hiera('openvpn_network')
  $port = hiera('openvpn_port')
  $basedir = "/etc/openvpn/${servername}"

  openvpn::server { $servername:
    country => 'RU',
    province => 'RU',
    city => 'Moscow',
    organization => 'example',
    email => 'e@example.org',
    server => $server,
    user => 'nobody',
    group => 'nobody',
    port => $port,
    proto => 'tcp',
    dev => 'tun',
    push => ['redirect-gateway'],
    keepalive => '10 120',
    compression => 'comp-lzo',
    persist_key => true,
    persist_tun => true,
    local => '',
  } ->

  # rewrite default keys. It's a dirty way, but upstream module doesn't support
  # predefined set of keys
  file {
    "${basedir}/keys/ca.crt":
      content => hiera('openvpn_cacrt');
    "${basedir}/keys/ca.key":
      content => hiera('openvpn_cakey');
    "${basedir}/keys/server.crt":
      content => hiera('openvpn_servercrt');
    "${basedir}/keys/server.key":
      content => hiera('openvpn_serverkey');
  } ~> Service['openvpn']
}

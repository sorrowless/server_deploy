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
  }

  openvpn::client { 'client':
    server => $servername,
    port => $port,
  }
}

class vps::sysctl (
){
  
  sysctl::value { 'net.ipv4.ip_forward': value => '1' }
}

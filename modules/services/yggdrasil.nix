{ ... }:

{
  services.yggdrasil = {
    enable = true;
    persistentKeys = true;
    settings = {
      Peers = [
        "tls://188.225.9.167:18227"
        "tls://yggno.de:18227"
        "tcp://srv.itrus.su:7991"
        "tcp://kazi.peer.cofob.ru:18000"
        "tls://yggpvs.duckdns.org:8443"
        "tcp://box.paulll.cc:13337"
        "tcp://kusoneko.moe:9002"
        "tls://[2607:5300:201:3100::50a1]:58226"
        "tls://192.99.145.61:58226"
        "tls://ca1.servers.devices.cwinfo.net:58226"
        "tls://95.216.5.243:18836"
        "tls://65.21.57.122:61995"
        "tls://[2a01:4f9:2a:60c::2]:18836"
        "tls://[2a01:4f9:c010:664d::1]:61995"
        "tls://fi1.servers.devices.cwinfo.net:61995"
        "tls://aurora.devices.waren.io:18836"
        "tcp://ygg-fin.incognet.io:8883"
        "tls://ygg-fin.incognet.io:8884"
      ];
      Listen = [
        "tls://0.0.0.0:0"
        "tls://[::]:0"
      ];
      AdminListen = "unix:///var/run/yggdrasil/yggdrasil.sock";
      MulticastInterfaces = [
        {
          Regex = ".*";
          Beacon = true;
          Listen = true;
          Port = 0;
        }
      ];
      AllowedPublicKeys = [ ];
      IfName = "yg0";
      NodeInfoPrivacy = true;
    };
  };
}

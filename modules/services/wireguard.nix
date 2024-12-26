{ ... }:

{
  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  };

  networking.wg-quick.interfaces.wg0 = {
    address = [
      "10.13.0.2/24"
      "fd86:ea04:1115::2/128"
    ];
    dns = [ "10.13.0.1" ];
    listenPort = 51820;
    privateKeyFile = "/etc/wg0.pk";

    peers = [
      {
        publicKey = "AblSEgygxUWYMY+f1iwSlhh2RANyx64nnS5kSv3pTD4=";
        allowedIPs = [ "0.0.0.0/0" ];
        endpoint = "faptek.ml:1642";
        persistentKeepalive = 25;
      }
    ];
  };
}

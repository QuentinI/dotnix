{ config, pkgs, ...}:

{
  services.zerotierone = {
    enable = true;
    joinNetworks = [ "8bd5124fd62082f4" ];
  };
}

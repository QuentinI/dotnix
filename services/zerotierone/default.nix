{ config, pkgs, ...}:

{
  services.zerotierone = {
    enable = true;
    joinNetworks = [ "8bd5124fd62082f4" "159924d630859a41" ];
  };
}

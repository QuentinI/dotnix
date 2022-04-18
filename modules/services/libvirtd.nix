{ config, pkgs, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    qemu = { package = pkgs.qemu; };
  };
}

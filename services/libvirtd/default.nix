{ config, pkgs, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    qemuPackage = pkgs.qemu;
  };
}

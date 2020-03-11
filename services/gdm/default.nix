{ config, pkgs, ... }:

{
  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
    autoLogin = {
      enable = true;
      user = "quentin";
    };
  };
}

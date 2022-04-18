{ config, pkgs, vars, ... }:

{
  services.xserver = {
    enable = true;
    libinput.enable = true;
    displayManager = {
      defaultSession = "sway";
      gdm = {
        enable = true;
        wayland = true;
      };
    };
    config = "";
    layout = "us,ru";
  };
}

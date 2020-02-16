{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    libinput.enable = true;
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
    };
    videoDrivers = [ "nvidia" ];
    displayManager.sddm.enable = true;
    config = "";
    layout = "us,ru";
  };
}

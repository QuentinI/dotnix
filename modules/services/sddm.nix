{ config, pkgs, vars, ... }:

{
  services.xserver = {
    enable = true;
    libinput.enable = true;
    videoDrivers = [ "nouveau" "intel" ];
    displayManager = {
      defaultSession = "sway";
      sddm = {
        enable = true;
        settings.Users.HideUsers = "jupyter";
      };
    };
    config = "";
    layout = "us,ru";
  };
}

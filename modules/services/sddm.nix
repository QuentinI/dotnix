{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    libinput.enable = true;
    # videoDrivers = [ "nouveau" "intel" ];
    displayManager = {
      # sessionPackages = [ pkgs.sway ];
      # defaultSession = "sway";
      sddm = {
        enable = true;
        # settings.Users.HideUsers = "jupyter";
      };
    };
    config = "";
    layout = "us,ru";
  };
}

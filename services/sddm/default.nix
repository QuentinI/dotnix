{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    libinput.enable = true;
    videoDrivers = [ "intel" ];
    displayManager.sddm = {
      sessionPackages = [ pkgs.sway ];
      enable = true;
      autoLogin = {
        enable = true;
        user = "quentin";
      };
      extraConfig = ''
        [Users]
        HideUsers=jupyter
      '';
    };
    config = "";
    layout = "us,ru";
  };
}

{ config, pkgs, vars, ... }:

{
  environment.systemPackages = [ pkgs.qt5.qtwayland pkgs.sway ];

  security.pam.services.swaylock = { };

  services.xserver = {
    displayManager = {
      sessionPackages = [ pkgs.sway ];
      defaultSession = "sway";
    };
  };
}

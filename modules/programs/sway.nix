{ config, pkgs, vars, ... }:

let
  sway = pkgs.sway.override { extraOptions = [ "--unsupported-gpu" "--verbose" ]; };
in
{
  environment.systemPackages = [ pkgs.qt5.qtwayland sway ];

  security.pam.services.swaylock = { };

  services.xserver = {
    displayManager = {
      sessionPackages = [ sway ];
      defaultSession = "sway";
    };
  };
}

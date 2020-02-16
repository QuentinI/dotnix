{ config, pkgs, ...}:

{
  home.packages = [ pkgs.guake ];
  systemd.user.services.guake = {
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.guake}/bin/guake";
      Restart = "on-abort";
    };
  };
}

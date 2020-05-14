{ config, pkgs, ...}:

let
  startScript = pkgs.writeShellScriptBin "jackett.sh" ''
    ${pkgs.jackett}/bin/Jackett --ListenPrivate --ProxyConnection 127.0.0.1:1080 --NoUpdates
  '';
in

{
  home.packages = with pkgs; [ jackett ];
  systemd.user.services.jackett = {
      Install = {
          WantedBy = [ "graphical-session.target" ];
      };
      Service = {
          ExecStart = "${startScript}/bin/jackett.sh";
          Restart = "on-abort";
      };
  };
}

{ config, pkgs, ... }:

let
  startScript = pkgs.writeShellScriptBin "sonarr.sh" ''
    ${pkgs.sonarr}/bin/NzbDrone
  '';

in {
  home.packages = with pkgs; [ sonarr ];
  systemd.user.services.sonarr = {
    Install = { WantedBy = [ "graphical-session.target" ]; };
    Service = {
      ExecStart = "${startScript}/bin/sonarr.sh";
      Restart = "on-abort";
    };
  };
}

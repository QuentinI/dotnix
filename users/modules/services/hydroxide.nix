{ config, pkgs, ... }:

let
  startScript = pkgs.writeShellScriptBin "hydroxide.sh" ''
    HTTPS_PROXY=socks5://127.0.0.1:1080 ${pkgs.hydroxide}/bin/hydroxide serve
  '';

in {
  home.packages = with pkgs; [ hydroxide ];
  systemd.user.services.hydroxide = {
    Install = { WantedBy = [ "graphical-session.target" ]; };
    Service = {
      ExecStart = "${startScript}/bin/hydroxide.sh";
      Restart = "on-abort";
    };
  };
}

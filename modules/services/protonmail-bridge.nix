{
  home =
    { pkgs, ... }:
    let
      startScript = pkgs.writeShellScriptBin "bridge.sh" ''
        export HTTPS_PROXY=socks5://127.0.0.1:1080
        ${pkgs.protonmail-bridge}/bin/protonmail-bridge
      '';
    in
    {
      home.packages = with pkgs; [
        pass
        protonmail-bridge
      ];
      systemd.user.services.pm-bridge = {
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${startScript}/bin/bridge.sh";
          Restart = "on-abort";
        };
      };
    };
}

{
  config,
  pkgs,
  secrets,
  ...
}:

let
  cfg = pkgs.writeText "config.json" (
    if builtins.hasAttr "shadowsocks" secrets then (builtins.toJSON secrets.shadowsocks) else ""
  );

  startScript = pkgs.writeShellScriptBin "shadowsocks.sh" ''
    ${pkgs.shadowsocks-rust}/bin/sslocal -c ${cfg}
  '';

in
{
  systemd.user.services.shadowsocks = {
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Unit = {
      After = [ "network.target" ];
    };
    Service = {
      ExecStart = "${startScript}/bin/shadowsocks.sh";
      Restart = "on-failure";
    };
  };
}

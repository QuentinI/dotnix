{ config, pkgs, secrets, ... }:

let
  cfg = pkgs.writeText "config.json" (if builtins.hasAttr "shadowsocks" secrets then (builtins.toJSON secrets.shadowsocks) else "");

  startScript = pkgs.writeShellScriptBin "shadowsocks.sh" ''
    SS=${pkgs.shadowsocks-libev}/bin/ss-local
    PASS=${pkgs.pass}/bin/pass
    HEAD=${pkgs.coreutils}/bin/head
    TAIL=${pkgs.coreutils}/bin/tail
    $SS -c ${cfg}
  '';

in {
  systemd.user.services.shadowsocks = {
    Install = { WantedBy = [ "graphical-session.target" ]; };
    Service = {
      ExecStart = "${startScript}/bin/shadowsocks.sh";
      Restart = "on-abort";
    };
  };
}

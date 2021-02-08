{ config, pkgs, ... }:

let
  cfg = pkgs.writeText "config.json" ''
    {
       "local_address": "127.0.0.1",
       "local_port":1080,
       "timeout":300,
       "fast_open": false,
       "workers": 1
    }
  '';

  startScript = pkgs.writeShellScriptBin "shadowsocks.sh" ''
    SS=${pkgs.shadowsocks-libev}/bin/ss-local
    PASS=${pkgs.pass}/bin/pass
    HEAD=${pkgs.coreutils}/bin/head
    TAIL=${pkgs.coreutils}/bin/tail
    $SS -c ${cfg} -k $($PASS show Shadowsocks/Elijah | $HEAD -n 1) $($PASS show Shadowsocks/Elijah | $TAIL -n 1)
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

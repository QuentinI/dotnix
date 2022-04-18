{ pkgs, ... }:

{
  home.packages = [
    pkgs.activitywatch.aw-qt
    pkgs.activitywatch.aw-server-rust
    pkgs.activitywatch.aw-watcher-window-wayland
  ];

  systemd.user.services.activitywatch = {
    Unit = {
      Description = "activitywatch server";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.activitywatch.aw-server-rust}/bin/aw-server";
      Restart = "on-abort";
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };
  };

  systemd.user.services.activitywatch-wayland = {
    Unit = {
      Description = "activitywatch server";
      After = [ "graphical-session-pre.target" "activitywatch.service" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.activitywatch.aw-watcher-window-wayland}/bin/aw-watcher-window-wayland";
      Restart = "on-abort";
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };
  };
}

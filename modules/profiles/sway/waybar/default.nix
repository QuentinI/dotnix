{
  home =
    { config, pkgs, ... }:
    let
      waybar = (
        pkgs.waybar.override {
          pulseSupport = true;
          traySupport = true;
        }
      );
    in
    {
      home.packages = [ waybar ];

      # Waybar works with libappindicator tray icons only
      xsession.preferStatusNotifierItems = true;

      xdg.configFile.waybar_config = {
        source = ./waybar_config.json;
        target = "waybar/config";
      };

      xdg.configFile.waybar_style = {
        text =
          with config.lib.stylix.colors;
          ''
            @define-color base00 #${base00};
            @define-color base01 #${base01};
            @define-color base02 #${base02};
            @define-color base03 #${base03};
            @define-color base04 #${base04};
            @define-color base05 #${base05};
            @define-color base06 #${base06};
            @define-color base07 #${base07};
            @define-color base08 #${base08};
            @define-color base09 #${base09};
            @define-color base0A #${base0A};
            @define-color base0B #${base0B};
            @define-color base0C #${base0C};
            @define-color base0D #${base0D};
            @define-color base0E #${base0E};
            @define-color base0F #${base0F};
          ''
          + builtins.readFile ./waybar_style.css;
        target = "waybar/style.css";
      };

      wayland.windowManager.sway.config = {
        bars = [
          {
            command = "${waybar}/bin/waybar";
            position = "bottom";
          }
        ];
      };
    };
}

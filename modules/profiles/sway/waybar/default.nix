{
  home = { config, pkgs, ... }:
    let waybar = (pkgs.waybar.override {
      pulseSupport = true;
      traySupport = true;
    }); in
    {
      home.packages = [ waybar ];

      # Waybar works with libappindicator tray icons only
      xsession.preferStatusNotifierItems = true;

      xdg.configFile.waybar_config = {
        source = ./waybar_config.json;
        target = "waybar/config";
      };

      xdg.configFile.waybar_style = {
        text = with config.theme.base16.colors; ''
          @define-color base00 #${base00.hex.rgb};
          @define-color base01 #${base01.hex.rgb};
          @define-color base02 #${base02.hex.rgb};
          @define-color base03 #${base03.hex.rgb};
          @define-color base04 #${base04.hex.rgb};
          @define-color base05 #${base05.hex.rgb};
          @define-color base06 #${base06.hex.rgb};
          @define-color base07 #${base07.hex.rgb};
          @define-color base08 #${base08.hex.rgb};
          @define-color base09 #${base09.hex.rgb};
          @define-color base0A #${base0A.hex.rgb};
          @define-color base0B #${base0B.hex.rgb};
          @define-color base0C #${base0C.hex.rgb};
          @define-color base0D #${base0D.hex.rgb};
          @define-color base0E #${base0E.hex.rgb};
          @define-color base0F #${base0F.hex.rgb};
        '' + builtins.readFile ./waybar_style.css;
        target = "waybar/style.css";
      };

      wayland.windowManager.sway.config = {
        bars = [{
          command = "${waybar}/bin/waybar";
          position = "bottom";
        }];
      };
    };
}

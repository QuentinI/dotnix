{
  home =
    { config, pkgs, ... }:

    {
      home.packages = with pkgs; [ mako ];

      stylix.targets.mako.enable =true;
      xdg.configFile.mako = {
        text = ''
          max-visible=3
          layer=top
          anchor=top-right
          font=Fira Code 16
          sort=+time
          width=580
          height=150
          format=%s\n<small>%b</small>
          default-timeout=60000
        '';
        target = "mako/config";
      };

      systemd.user.services.mako = {
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.mako}/bin/mako";
          Restart = "on-abort";
        };
      };
    };
}

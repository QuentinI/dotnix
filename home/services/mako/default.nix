{ config, pkgs, ...}:

let
  theme    = import ../../themes { inherit pkgs; };
in
{
  home.packages = with pkgs; [ mako ];

  xdg.configFile.mako = {
    text = ''
      max-visible=3
      layer=top
      anchor=top-right
      font=Fira Code 16
      sort=+time
      background-color=${theme.colors.background.primary}
      text-color=${theme.colors.text.primary}
      border-color=${theme.colors.background.inverted}
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
}

{ config, pkgs, ... }:

{
  home.packages = [ pkgs.kitty ];

  stylix.targets.kitty.enable = true;
  xdg.configFile.kitty_config = {
    target = "kitty/kitty.conf";
    text = ''
      # WTF, really
      enable_audio_bell no

      # Nice in theory, misfires in practice
      confirm_os_window_close 0

      # Font
      font_family  Fira Code
      font_size    15.0

      window_padding_width 8.0

    '';
  };
}

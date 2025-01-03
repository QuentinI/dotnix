{ config, pkgs, ... }:

{
  home.packages = [ pkgs.kitty ];

  # TODO: what are those color{0..15} thingies and why do i have them
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

      # Cursor
      cursor                #${config.theme.base16.colors.base04.hex.rgb}

      # Colors
      foreground            #${config.theme.base16.colors.base04.hex.rgb}
      background            #${config.theme.base16.colors.base00.hex.rgb}
      selection_foreground  #${config.theme.base16.colors.base04.hex.rgb}
      selection_background  #${config.theme.base16.colors.base01.hex.rgb}

      color0    #3b4252
      color1    #bf616a
      color2    #a3be8c
      color3    #ebcb8b
      color4    #81a1c1
      color5    #b48ead
      color6    #88c0d0
      color7    #e5e9f0
      color8    #4c566a
      color9    #bf616a
      color10   #a3be8c
      color11   #ebcb8b
      color12   #81a1c1
      color13   #b48ead
      color14   #8fbcbb
      color15   #eceff4

    '';
  };
}

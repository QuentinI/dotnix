{ config, pkgs, ... }:

let
  theme = import ../../themes {inherit pkgs; };
in
{
  home.packages = [
    pkgs.kitty
  ];

  # TODO: what are those color{0..15} thingies and why do i have them
  xdg.configFile.kitty_config = {
    target = "kitty/kitty.conf";
    text = ''
      # WTF, really
      enable_audio_bell no

      # Font
      font_family  Fira Code
      font_size    13.0

      window_padding_width 8.0

      # Cursor
      cursor                ${theme.colors.text.primary}

      # Colors
      foreground            ${theme.colors.text.primary}
      background            ${theme.colors.background.primary} 
      selection_foreground  ${theme.colors.text.selection}
      selection_background  ${theme.colors.background.selection}

      color0 			#3b4252
      color1 			#bf616a
      color2 			#a3be8c
      color3 			#ebcb8b
      color4 			#81a1c1
      color5 			#b48ead
      color6 			#88c0d0
      color7 			#e5e9f0
      color8 			#4c566a
      color9 			#bf616a
      color10 		#a3be8c
      color11 		#ebcb8b
      color12 		#81a1c1
      color13 		#b48ead
      color14 		#8fbcbb
      color15 		#eceff4

    '';
  };
}

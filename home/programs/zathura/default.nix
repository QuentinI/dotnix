{config, pkgs, ...}:

let
  theme = import ../../themes { inherit pkgs; };
in

{
  xdg.configFile.zathurarc = {
    target = "zathura/zathurarc";
    text = 
      ''
      set default-bg "${theme.colors.background.primary}"
      set statusbar-bg "${theme.colors.background.primary}"
      set recolor-lightcolor "${theme.colors.background.primary}"
      set selection-clipboard clipboard
      '';
  };
}

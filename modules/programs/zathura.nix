{ config, pkgs, ... }:

{
  xdg.configFile.zathurarc = {
    target = "zathura/zathurarc";
    text = ''
      set default-bg "#${config.theme.base16.colors.base00.hex.rgb}"
      set statusbar-bg "#${config.theme.base16.colors.base00.hex.rgb}"
      set recolor-lightcolor "#${config.theme.base16.colors.base00.hex.rgb}"
      set selection-clipboard clipboard
    '';
  };
}

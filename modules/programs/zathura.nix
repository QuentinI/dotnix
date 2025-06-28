{ config, ... }:

{
  stylix.targets.zathura.enable = true;
  xdg.configFile.zathurarc = {
    target = "zathura/zathurarc";
    text = ''
      set selection-clipboard clipboard
    '';
  };
}

# TODO theme
{ config, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    lines = 7;
    font = "Fira Code 16";
    extraConfig = {
      modi = "drun";
      matching = "fuzzy";
      drun-match-fields = "name";
      drun-display-format = "{name}";
      kb-row-select = "ctrl+shift+space";
      kb-cancel = "Menu,Escape,alt+r";
      show-icons = "true";
      kb-row-tab = "shift+Tab";
    };

    enableBase16Theme = false;

    colors = {
      window = {
        background = "#${config.theme.base16.colors.base01.hex.rgb}";
        border = "#${config.theme.base16.colors.base04.hex.rgb}";
        separator = "#${config.theme.base16.colors.base04.hex.rgb}";
      };

      rows = {
        normal = {
          background = "#${config.theme.base16.colors.base01.hex.rgb}";
          foreground = "#${config.theme.base16.colors.base04.hex.rgb}";
          backgroundAlt = "#${config.theme.base16.colors.base01.hex.rgb}";
          highlight = {
            background = "#${config.theme.base16.colors.base04.hex.rgb}";
            foreground = "#${config.theme.base16.colors.base00.hex.rgb}";
          };
        };
      };
    };
  };
}

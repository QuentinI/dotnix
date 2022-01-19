# TODO theme
{ config, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    font = "Fira Code 16";
    extraConfig = {
      modi = "drun";
      matching = "fuzzy";
      drun-match-fields = "name";
      drun-display-format = "{name}";
      kb-row-select = "ctrl+shift+space";
      kb-cancel = "Menu,Escape,alt+r";
      show-icons = true;
      kb-row-tab = "shift+Tab";
    };

    enableBase16Theme = true;
  };
}

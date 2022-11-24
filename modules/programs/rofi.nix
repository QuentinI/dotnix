# TODO theme
{ config, pkgs, inputs, ... }:

{
  programs.rofi = {
    enable = true;
    font = "Fira Code 16";
    package = pkgs.rofi-wayland;
    extraConfig = {
      modi = "drun";
      matching = "fuzzy";
      drun-match-fields = "name";
      drun-display-format = "{name}";
      kb-row-select = "ctrl+shift+space";
      kb-cancel = "Menu,Escape,alt+r";
      show-icons = true;
      icon-theme = config.gtk.iconTheme.name;
      kb-row-tab = "shift+Tab";
    };

    enableBase16Theme = true;
  };
}

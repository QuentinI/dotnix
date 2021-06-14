{ config, pkgs, inputs, ... }:

{
  programs.bat = {
    enable = true;
    config = {
      paging = "never";
      color = "always";
    };
  };

  home = {
    activation = {
      batCache = inputs.home.lib.hm.dag.entryAfter ["writeBoundary"] ''
        ${pkgs.bat}/bin/bat cache --build
      '';
    };
  };
}

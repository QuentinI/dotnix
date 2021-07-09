{ pkgs, ... }:

let
in
  {
    home.packages = with pkgs; [ emacsPgtkGcc sqlite python3Packages.black python3Packages.nose python3Packages.editorconfig graphviz grip shaderc ];
    services.emacs = {
      enable = true;
      package = pkgs.emacsPgtkGcc;
    };
  }

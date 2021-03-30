{ pkgs, ... }:

let
in
  {
    home.packages = with pkgs; [ sqlite python3Packages.black python3Packages.nose python3Packages.editorconfig graphviz grip shaderc ];
  }

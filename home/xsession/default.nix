{ config, pkgs, ... }:

let
  theme = import ../themes { inherit pkgs; };
in
{
  imports = [
    ./sway
    ./mime.nix
  ];
  # xsession.enable = true;
  xresources.extraConfig = theme.xresources;
}

{ config, pkgs, ... }:

{
  imports = [
    ./browserpass
    ./zsh
    ./most
    ./mopidy
    ./ncmpcpp
    ./iex
    ./tdesktop
    ./nvim
    ./kitty
    ./zathura
    ./beets
    ./firefox
    ./fzf
    ./bat
  ];
}

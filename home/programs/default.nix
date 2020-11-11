{ config, pkgs, ... }:

{
  imports = [
    ./browserpass
    ./zsh
    ./most
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
    ./git
  ];
}

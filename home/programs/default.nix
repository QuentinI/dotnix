{ config, pkgs, ... }:

{
  imports = [
    ./emacs
    ./qutebrowser
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

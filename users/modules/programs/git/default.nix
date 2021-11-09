{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userEmail = "mbee@protonmail.ch";
    userName = "Quentin Inkling";
    signing = {
      signByDefault = true;
      key = "01A58C7ACB1DA90765A880AEE28458FC0D7D0180";
    };
    extraConfig = {
      diff.algorithm = "histogram";
    };
  };
}

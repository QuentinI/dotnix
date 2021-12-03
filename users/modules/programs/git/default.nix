{ config, pkgs, system, staging, ... }:

{
  programs.git = {
    enable = true;
    package = staging.git;
    userEmail = "mbee@protonmail.ch";
    userName = "Quentin Inkling";
    signing = {
        signByDefault = true;
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJpRgKD6LSnGjc2lid5nOzdWrst6Ri6mqJ1B3LFQaDzl";
    };
    extraConfig = {
      diff.algorithm = "histogram";
      gpg.format = "ssh";
      gpg.ssh.program = "${staging.openssh}/bin/ssh-keygen";
    };
  };
}

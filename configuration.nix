{ config, pkgs, options, ... }:

let sources = import ./nix/sources.nix;
in {
  imports = [
    <home-manager/nixos>
    ./hosts/utumno
  ];

  nix.nixPath =
    options.nix.nixPath.default ++ 
    [ "nixpkgs-overlays=/etc/nixos/overlays/" ];

  nixpkgs.config.allowUnfree = true;

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  i18n.defaultLocale = "en_US.UTF-8";

  home-manager.useUserPackages = true;

  users.mutableUsers = false;
}

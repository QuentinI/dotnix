inputs@{ system, master, nixos, stable, home, vars, secrets, ... }:

nixos.lib.nixosSystem {
  inherit system;

  # Things in this set are passed to modules and accessible
  # in the top-level arguments (e.g. `{ pkgs, lib, inputs, ... }:`).
  specialArgs = { inherit inputs vars secrets; };

  modules = [
    home.nixosModules.home-manager

    ./hardware.nix
    ./configuration.nix
    ./user.nix

    ../../modules/profiles/base.nix
    ../../modules/profiles/silent-boot.nix
    ../../modules/profiles/hardened.nix

    ../../modules/services/sddm.nix
    ../../modules/services/docker.nix
    ../../modules/services/libvirtd.nix
    ../../modules/services/jupyter.nix
    ../../modules/services/zerotierone.nix

    ../../modules/programs/sway.nix
  ];

}

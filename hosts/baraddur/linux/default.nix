{
  system = "aarch64-linux";
  configuration =
    inputs@{
      system,
      nixpkgs,
      home,
      vars,
      secrets,
      hostname,
      mkImports,
      ...
    }:

    nixpkgs.lib.nixosSystem rec {
      inherit system;

      # Things in this set are passed to modules and accessible
      # in the top-level arguments (e.g. `{ pkgs, lib, inputs, ... }:`).
      specialArgs = {
        inherit
          inputs
          vars
          secrets
          system
          hostname
          mkImports
          ;
      };

      modules = mkImports "nixos" [
        (
          {
            config,
            lib,
            pkgs,
            ...
          }:
          {
            config.nixpkgs.overlays =
              inputs.overlays
              ++ [ inputs.apple-silicon.overlays.apple-silicon-overlay ]
              ++ [ (import ../../overlays/default.nix) ];
            # Some black magic fuckery to inject specialArgs into HM configuration
            options.home-manager.users = lib.mkOption {
              type =
                with lib.types;
                attrsOf (submoduleWith {
                  inherit specialArgs;
                  modules = [ ];
                });
            };
          }
        )
        home.nixosModules.home-manager

        inputs.apple-silicon.nixosModules.apple-silicon-support

        ./hardware.nix
        ./configuration.nix
        ./user.nix

        ../../modules/profiles/base.nix
        ../../modules/profiles/silent-boot.nix
        ../../modules/profiles/hardened.nix
        ../../modules/profiles/audio.nix
        ../../modules/profiles/udev/backlight.nix
        ../../modules/profiles/sway

        ../../modules/services/docker.nix
        ../../modules/services/libvirtd.nix
        ../../modules/services/zerotierone.nix
        # ../../modules/services/wireguard.nix
        ../../modules/services/yggdrasil.nix
        ../../modules/services/i2p.nix
        ../../modules/services/tor.nix
        ../../modules/services/udiskie.nix

      ];
    };
}

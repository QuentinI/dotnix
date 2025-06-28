{
  system = "aarch64-linux";
  configuration =
    inputs@{
      system,
      flake-inputs,
      vars,
      secrets,
      hostname,
      mkImports,
      nur,
      ...
    }:

    flake-inputs.nixpkgs.lib.nixosSystem rec {
      inherit system;

      # Things in this set are passed to modules and accessible
      # in the top-level arguments (e.g. `{ pkgs, lib, inputs, ... }:`).
      specialArgs = {
        inherit
        flake-inputs
          nur
          inputs
          vars
          secrets
          system
          hostname
          mkImports
          ;
      };

      modules = [
        (
          {
            config,
            lib,
            pkgs,
            ...
          }:
          {
            config.stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
  config.stylix.image = pkgs.fetchurl {
    url = "https://www.pixelstalk.net/wp-content/uploads/2016/05/Epic-Anime-Awesome-Wallpapers.jpg";
    sha256 = "enQo3wqhgf0FEPHj2coOCvo7DuZv+x5rL/WIo4qPI50=";
  };
            config.stylix.autoEnable = false;
            config.nixpkgs.overlays =
              inputs.overlays
              ++ [ flake-inputs.apple-silicon.overlays.apple-silicon-overlay ]
              ++ [ (import ../../../overlays/default.nix) ];
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
        flake-inputs.home.nixosModules.home-manager
        flake-inputs.stylix.nixosModules.stylix

        flake-inputs.apple-silicon.nixosModules.apple-silicon-support

        ./hardware.nix
        ./configuration.nix
        ./user.nix
     ]
     ++ mkImports "nixos" [

        ../../../modules/profiles/base.nix
        ../../../modules/profiles/silent-boot.nix
        ../../../modules/profiles/hardened.nix
        ../../../modules/profiles/audio.nix
        ../../../modules/profiles/udev/backlight.nix
        ../../../modules/profiles/sway

        ../../../modules/services/docker.nix
        ../../../modules/services/libvirtd.nix
        ../../../modules/services/zerotierone.nix
        #../../../modules/services/wireguard.nix
        ../../../modules/services/yggdrasil.nix
        ../../../modules/services/i2p.nix
        ../../../modules/services/tor.nix
        ../../../modules/services/udiskie.nix

      ];
    };
}

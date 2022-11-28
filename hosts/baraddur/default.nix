inputs@{ system, master, nixpkgs, stable, staging, home, vars, secrets, hostname, mkImports, ... }:

{
  nixosConfiguration = nixpkgs.lib.nixosSystem rec {
    inherit system;

    # Things in this set are passed to modules and accessible
    # in the top-level arguments (e.g. `{ pkgs, lib, inputs, ... }:`).
    specialArgs = { inherit inputs vars secrets staging system hostname mkImports; };

    modules = mkImports "nixos" [
      ({ config, lib, pkgs, ... }: {
        config.nixpkgs.overlays = inputs.overlays
          ++ [ (import ../../overlays/apple-silicon.nix) ];
        # Some black magic fuckery to inject specialArgs into HM configuration
        options.home-manager.users = lib.mkOption {
          type = with lib.types;
            attrsOf (submoduleWith {
              inherit specialArgs;
              modules = [ ];
            });
        };
      })
      home.nixosModules.home-manager

      # This is https://github.com/tpwrules/nixos-m1
      # patched to support Lina and Alyssa's ongoing
      # GPU work.
      # If by any chance you stumble upon this:
      # PLEASE think twice before using this, there's a reason
      # Lina's driver isn't released yet. If you will still end
      # up using it - PLEASE don't go and complain to Asahi team
      # about your computer exploding or something, I don't want
      # to cause them problems. Don't complain to me either,
      # although you may ask questions.
      ./m1-support

      ./hardware.nix
      ./configuration.nix
      ./user.nix

      ../../modules/profiles/base.nix
      ../../modules/profiles/silent-boot.nix
      ../../modules/profiles/hardened.nix
      ../../modules/profiles/udev/backlight.nix
      ../../modules/profiles/sway

      ../../modules/services/docker.nix
      # ../../modules/services/libvirtd.nix
      ../../modules/services/zerotierone.nix
      # ../../modules/services/wireguard.nix
      ../../modules/services/yggdrasil.nix
      ../../modules/services/i2p.nix
      ../../modules/services/tor.nix
      ../../modules/services/udiskie.nix

    ];

  };
}

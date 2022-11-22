inputs@{ system, master, nixpkgs, stable, staging, home, vars, secrets, ... }:

{
  nixosConfiguration = nixpkgs.lib.nixosSystem rec {
    inherit system;

    # Things in this set are passed to modules and accessible
    # in the top-level arguments (e.g. `{ pkgs, lib, inputs, ... }:`).
    specialArgs = { inherit inputs vars secrets staging system; };

    modules = [
      ({ pkgs, ... }: {
        nixpkgs.overlays = inputs.overlays ++ [(self: super: {
          mesa = super.mesa.overrideAttrs (_: {
	    version = "22.3.0-rc4";
	  });
	})];
      })
      home.nixosModules.home-manager
      # Some black magic fuckery to inject specialArgs into HM configuration
      ({ config, lib, ... }: {
        options.home-manager.users = lib.mkOption {
          type = with lib.types;
            attrsOf (submoduleWith {
              inherit specialArgs;
              modules = [ ];
            });
        };

      })

      ./hardware.nix
      ./m1-support
      ./configuration.nix
      ./user.nix

      ../../modules/profiles/base.nix
      ../../modules/profiles/silent-boot.nix
      ../../modules/profiles/hardened.nix

      ../../modules/services/docker.nix
      ../../modules/services/libvirtd.nix
      ../../modules/services/zerotierone.nix
      ../../modules/services/fprintd.nix
      ../../modules/services/tlp.nix
      ../../modules/services/wireguard.nix
      ../../modules/services/yggdrasil.nix
      ../../modules/services/i2p.nix
      ../../modules/services/tor.nix

      ../../modules/programs/sway.nix
    ];

  };

  deploy = { };
}

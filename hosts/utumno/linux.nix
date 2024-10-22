{
  system = "x86_64-linux";
  configuration =
    inputs@{
      system,
      master,
      nixpkgs,
      stable,
      home,
      vars,
      secrets,
      ...
    }:
    nixpkgs.lib.nixosSystem rec {
      inherit system;

      # Things in this set are passed to modules and accessible
      # in the top-level arguments (e.g. `{ pkgs, lib, inputs, ... }:`).
      specialArgs = {
        inherit inputs vars secrets;
      };

      modules = [
        home.nixosModules.home-manager
        # Some black magic fuckery to inject specialArgs into HM configuration
        (
          { config, lib, ... }:
          {
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

        ./hardware.nix
        ./configuration.nix
        ./user.nix

        ../../modules/profiles/base.nix
        ../../modules/profiles/silent-boot.nix
        ../../modules/profiles/hardened.nix
        ../../modules/profiles/sway.nix

        ../../modules/services/sddm.nix
        ../../modules/services/docker.nix
        ../../modules/services/libvirtd.nix
        ../../modules/services/zerotierone.nix

      ];

    };
}

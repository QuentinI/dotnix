rec {
  system = "aarch64-darwin";

  configuration =
    inputs@{
      flake-inputs,
      nur,
      vars,
      pkgs-stable,
      mkImports,
      ...
    }:
    flake-inputs.nix-darwin.lib.darwinSystem {
      inherit system;

      modules =
        [
          { nixpkgs.overlays = [ flake-inputs.nixpkgs-firefox-darwin.overlay ]; }

          flake-inputs.lix-module.nixosModules.default
          flake-inputs.home.darwinModules.home-manager

          ./configuration.nix
          ./user.nix

        ]
        ++ mkImports "darwin" [

          ../../../modules/profiles/base.nix
          ../../../modules/programs/nix.nix
          ../../../modules/programs/firefox
          ../../../modules/programs/zsh/default.nix

        ];

      # Things in this set are passed to modules and accessible
      # in the top-level arguments (e.g. `{ pkgs, lib, inputs, ... }:`).
      specialArgs = {
        inherit
          vars
          nur
          mkImports
          pkgs-stable
          flake-inputs
          inputs
          ;
      };
    };
}

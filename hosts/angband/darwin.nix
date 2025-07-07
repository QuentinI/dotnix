{
  system = "aarch64-darwin";
  configuration =
    {
      flake-inputs,
      system,
      vars,
      secrets,
      hostname,
      mkImports,
      nur,
      pkgs-stable,
      ...
    }:

    flake-inputs.nix-darwin.lib.darwinSystem rec {
      inherit system;

      modules =
        [
          {
            nixpkgs.overlays = [
              flake-inputs.nvim.overlays."${system}".default
              flake-inputs.nixpkgs-firefox-darwin.overlay
              (import ../../overlays)
            ];
          }

          flake-inputs.lix-module.nixosModules.default
          flake-inputs.home.darwinModules.home-manager

          ./configuration.nix
          ./user.nix

        ]
        ++ mkImports "darwin" [

          ../../modules/profiles/base.nix
          ../../modules/programs/nix.nix
          ../../modules/programs/firefox
          ../../modules/programs/zsh/default.nix

        ];

      # Things in this set are passed to modules and accessible
      # in the top-level arguments (e.g. `{ pkgs, lib, inputs, ... }:`).
      specialArgs = {
        inherit
          flake-inputs
          vars
          secrets
          system
          hostname
          mkImports
          nur
          pkgs-stable
          ;
      };
    };
}

{ inputs, system, nixpkgs, home, vars, secrets, hostname, mkImports, nix-darwin, nur, ... }:

{
  darwinConfiguration = nix-darwin.lib.darwinSystem rec {
    inherit system;

    modules = [
      { nixpkgs.overlays = [ inputs.nixpkgs-firefox-darwin.overlay ]; }

      home.darwinModules.home-manager

      ./configuration.nix
      ./user.nix


    ] ++ mkImports "darwin" [

      ../../modules/profiles/base.nix
      ../../modules/programs/nix.nix
      ../../modules/programs/zsh/default.nix

    ];

    # Things in this set are passed to modules and accessible
    # in the top-level arguments (e.g. `{ pkgs, lib, inputs, ... }:`).
    specialArgs = { inherit inputs vars secrets system hostname mkImports nur; };
  };
}

{
system = "aarch64-darwin";
configuration = 
{ inputs, system, nixpkgs, home, vars, secrets, hostname, mkImports, nix-darwin, nur, lix-module, pkgs-stable, ... }:

nix-darwin.lib.darwinSystem rec {
    inherit system;

    modules = [
      { nixpkgs.overlays = [ inputs.nixpkgs-firefox-darwin.overlay ]; }

      lix-module.nixosModules.default
      home.darwinModules.home-manager

      ./configuration.nix
      ./user.nix


    ] ++ mkImports "darwin" [

      ../../modules/profiles/base.nix
      ../../modules/programs/nix.nix
      ../../modules/programs/firefox
      ../../modules/programs/zsh/default.nix

    ];

    # Things in this set are passed to modules and accessible
    # in the top-level arguments (e.g. `{ pkgs, lib, inputs, ... }:`).
    specialArgs = { inherit inputs vars secrets system hostname mkImports nur pkgs-stable; };
};
}

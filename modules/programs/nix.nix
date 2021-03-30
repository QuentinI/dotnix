{ config, pkgs, inputs, vars, ...}:

{
  nix.extraOptions = "experimental-features = nix-command flakes";
  nix.package = pkgs.nixFlakes;
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
}

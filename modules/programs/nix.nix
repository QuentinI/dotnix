{ config, pkgs, inputs, vars, ...}:

{
  nix.extraOptions = "experimental-features = nix-command flakes";
  nix.package = pkgs.nixFlakes;
  nix.registry.nixpkgs.flake = inputs.nixos;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
}

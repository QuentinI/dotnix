{ config, pkgs, inputs, vars, ...}:

{

  nix = {
    extraOptions = "experimental-features = nix-command flakes";
    package = pkgs.nixFlakes;
    registry.nixpkgs.flake = inputs.nixpkgs;
    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    binaryCaches = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
  };

  nixpkgs.overlays = [ ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
}

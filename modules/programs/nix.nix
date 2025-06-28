{ pkgs, flake-inputs, ... }:

{

  nix = {
    extraOptions = "experimental-features = nix-command flakes ca-derivations";
    optimise.automatic = true;
    package = pkgs.nixVersions.stable;
    registry.nixpkgs.flake = flake-inputs.nixpkgs;
    settings = {
      #extra-deprecated-features = [ "url-literals" ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];

      trusted-users = [ "@wheel" ];
    };
  };

  nixpkgs.overlays = [ ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
}

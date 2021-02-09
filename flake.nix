{

  inputs = {
    master.url = "nixpkgs/master";
    nixos.url = "nixpkgs/nixos-unstable";
    stable.url = "nixpkgs/release-20.09";
    home.url = "github:nix-community/home-manager/master";
    flake-utils.url = "github:numtide/flake-utils/flatten-tree-system";
    nur = {
      flake = false; # NUR's flake support is... suboptimal
      url = "github:nix-community/NUR";
    };
    # devshell.url = "github:numtide/devshell";
    ci-agent.url = "github:hercules-ci/hercules-ci-agent";
    base16-nord-scheme = {
      flake = false;
      url = "github:spejamchr/base16-nord-scheme/master";
    };
    secrets.url = "github:QuentinI/dummy-flake";
  };

  outputs = inputs@{ master, nixos, stable, home, secrets, ... }:
  let
    hosts = import ./hosts;
    vars = {
      user = "quentin";
    };
  in rec {
    nixosConfigurations = builtins.mapAttrs (hostname: config: 
      config (inputs // { system = "x86_64-linux"; inherit vars secrets; })
    ) hosts;
  };
}

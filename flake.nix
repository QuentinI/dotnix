{

  inputs = {
    master.url = "nixpkgs/master";
    nixpkgs.url = "nixpkgs/nixos-unstable";
    stable.url = "nixpkgs/release-20.09";
    home.url = "github:nix-community/home-manager/master";
    flake-utils.url = "github:numtide/flake-utils/flatten-tree-system";
    deploy-rs.url = "github:serokell/deploy-rs";
    nur = {
      flake = false; # NUR's flake support is... suboptimal
      url = "github:nix-community/NUR";
    };
    vim-plug = {
      flake = false;
      url = "github:junegunn/vim-plug";
    };
    base16-nord-scheme = {
      flake = false;
      url = "github:spejamchr/base16-nord-scheme/master";
    };
    secrets.url = "github:QuentinI/dummy-flake";
  };

  outputs =
    inputs@{ self, master, nixpkgs, stable, home, secrets, deploy-rs, ... }:
    let
      hosts = import ./hosts;
      vars = { user = "quentin"; };
    in rec {
      nixosConfigurations = builtins.mapAttrs (hostname: config:
        (config (inputs // {
          system = "x86_64-linux";
          inherit vars secrets;
        })).nixosConfiguration) hosts;

      deploy.nodes = builtins.mapAttrs (hostname: config:
        let
          deploy = (config (inputs // {
            system = "x86_64-linux";
            inherit vars secrets;
          })).deploy;
        in nixpkgs.lib.recursiveUpdate deploy {
          sshUser = vars.user; # bug in deploy-rs
          user = "root";
          profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos
            self.nixosConfigurations."${hostname}";
        }) hosts;
    };
}

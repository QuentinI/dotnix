{

  inputs = {
    staging.url = "nixpkgs/staging";
    master.url = "nixpkgs/master";
    nixpkgs.url = "nixpkgs/nixos-unstable";
    stable.url = "nixpkgs/release-21.11";
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
    nord-dircolors = {
      flake = false;
      url = "github:arcticicestudio/nord-dircolors/master";
    };
    base16-solarized-scheme = {
      flake = false;
      url = "github:arzg/base16-solarized-scheme/master";
    };
    mpv-scripts = {
      flake = false;
      url = "github:wiiaboo/mpv-scripts/master";
    };
    mpv-chapters = {
      flake = false;
      url = "github:zxhzxhz/mpv-chapters/master";
    };
    mpv-search-page = {
      flake = false;
      url = "github:CogentRedTester/mpv-search-page/master";
    };
    mpv-user-input = {
      flake = false;
      url = "github:CogentRedTester/mpv-user-input/master";
    };
    mpv-scroll-list = {
      flake = false;
      url = "github:CogentRedTester/mpv-scroll-list/master";
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
        (config (inputs // rec {
          system = "x86_64-linux";
          staging = import inputs.staging { inherit system; };
          stable = import inputs.stable { inherit system; };
          master = import inputs.master { inherit system; };
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

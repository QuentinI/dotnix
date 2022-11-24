{

  inputs = {
    staging.url = "nixpkgs/staging";
    master.url = "nixpkgs/master";
    nixpkgs.url = "nixpkgs/nixos-unstable";
    stable.url = "nixpkgs/release-21.11";
    home.url = "github:nix-community/home-manager/master";
    flake-utils.url = "github:numtide/flake-utils/flatten-tree-system";
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
    naersk = {
      url = "github:nmattia/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-mozilla = {
      url = "github:mozilla/nixpkgs-mozilla";
      flake = false;
    };
    secrets.url = "github:QuentinI/dummy-flake";
  };

  outputs =
    inputs@{ self, master, nixpkgs, stable, home, secrets, naersk, flake-utils, ... }:
    let
      hosts = import ./hosts;
      vars = {
        user = "quentin";
        theme = "dark";
      };
    in
    flake-utils.lib.eachDefaultSystem (system: rec {
      packages = {
        nixosConfigurations = builtins.mapAttrs
          (hostname: config:
            (config (inputs // rec {
              common-cfg = {
                inherit system;
                config.allowUnfree = true;
              };
              inherit system;
              staging = import inputs.staging common-cfg;
              stable = import inputs.stable common-cfg;
              master = import inputs.master common-cfg;
              inherit vars secrets hostname;
              overlays = [
                (final: prev: {
                  naersk = final.pkgs.callPackage naersk { };
                  naerskUnstable =
                    let
                      nmo = import inputs.nixpkgs-mozilla final prev;
                      rust = (nmo.rustChannelOf {
                        date = "2022-04-06";
                        channel = "nightly";
                        sha256 = "vOGzOgpFAWqSlXEs9IgMG7jWwhsmouGHSRHwAcHyccs=";
                      }).rust;
                    in
                    naersk.lib.${system}.override {
                      cargo = rust;
                      rustc = rust;
                    };
                })
                (import ./packages)
              ];
            })).nixosConfiguration)
          hosts;
      };
    });
}

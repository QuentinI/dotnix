{

  inputs = {
    flake-utils.url = "github:numtide/flake-utils/flatten-tree-system";

    # Repos
    nixpkgs.url = "github:NixOS/nixpkgs";
    master.url = "github:NixOS/nixpkgs/master";
    home.url = "github:nix-community/home-manager/master";
    nur.url = "github:nix-community/NUR";

    apple-silicon = {
      url = "github:QuentinI/nixos-apple-silicon/dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Neovim configuration
    nvim = {
      url = "github:QuentinI/nvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    helix = { url = "github:pinelang/helix-tree-explorer/tree_explore"; };

    # Themes
    base16-unclaimed-schemes = {
      flake = false;
      url = "github:chriskempson/base16-unclaimed-schemes";
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
      url = "github:mk12/base16-solarized-scheme/main";
    };


    # various MPV scripts
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

    # Rustiness
    naersk = {
      url = "github:nmattia/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-mozilla = {
      url = "github:mozilla/nixpkgs-mozilla";
      flake = false;
    };

    # Manually substituted for actual secrets
    secrets.url = "github:QuentinI/dummy-flake";
  };

  outputs =
    inputs@{ self, nixpkgs, master, nur, home, secrets, naersk, flake-utils, ... }:
    let
      hosts = import ./hosts;
      mkImports = scope: imports:
        map
          (modspec:
            let mod =
              if builtins.isPath modspec then
                import modspec
              else modspec;
            in
            if builtins.isAttrs mod && builtins.hasAttr scope mod then
              builtins.getAttr scope mod
            else mod
          )
          imports;
      vars = {
        username = "quentin";
        fullname = "Quentin Inkling";
        theme = "dark";
      };
    in
    flake-utils.lib.eachDefaultSystem (system: rec {
      packages.nixosConfigurations = builtins.mapAttrs
        (hostname: config:
          (config (inputs // rec {
            common-cfg = {
              inherit system;
              config.allowUnfree = true;
            };
            inherit system;
            inherit vars secrets hostname mkImports;
            overlays = [
              (final: prev: {
                master = import master common-cfg;
              })
              (import ./packages)
              inputs.nvim.overlays."${system}".default
            ];
          })).nixosConfiguration)
        hosts;
    });
}

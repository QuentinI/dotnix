{

  inputs = {
    systems.url = "github:nix-systems/default";
    stylix.url = "github:danth/stylix";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.2-1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Repos
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    master.url = "github:NixOS/nixpkgs/master";
    home.url = "github:nix-community/home-manager/master";
    nur.url = "github:nix-community/NUR";

    apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-muvm-fex = {
      url = "github:pauljako/nixos-muvm-fex";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";

    # Neovim configuration
    nvim = {
      url = "github:QuentinI/nvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    telegram-desktop-patched = {
      url = "github:shwewo/telegram-desktop-patched";
    };

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

    # Manually substituted for actual secrets
    secrets.url = "github:QuentinI/dummy-flake";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-stable,
      master,
      nur,
      home,
      secrets,
      flake-utils,
      ...
    }:
    let
      hostnames = builtins.attrNames (builtins.readDir ./hosts);
      findSystem =
        path: system:
        let
          file = nixpkgs.lib.path.append path "${system}.nix";
          dir = nixpkgs.lib.path.append path "${system}/default.nix";
        in
        if (builtins.pathExists file) then
          import file
        else if (builtins.pathExists dir) then
          import dir
        else
          null;
      filterNull = attrs: nixpkgs.lib.filterAttrsRecursive (n: v: v != null) attrs;
      hosts = filterNull (
        builtins.foldl' nixpkgs.lib.recursiveUpdate { } (
          map (hostname: {
            darwinConfigurations.${hostname} = findSystem ./hosts/${hostname} "darwin";
            nixosConfigurations.${hostname} = findSystem ./hosts/${hostname} "linux";
          }) hostnames
        )
      );

      common-cfg = system: {
        inherit system;
        config.allowUnfree = true;
      };

      configurations = nixpkgs.lib.mapAttrsRecursiveCond (as: !(as ? "system")) (
        path: value:
        value.configuration rec {
          system = value.system;
          hostname = nixpkgs.lib.last path;
          pkgs = import inputs.nixpkgs (common-cfg  system);
          pkgs-stable = import inputs.nixpkgs-stable common-cfg (common-cfg  system);
          nur = import inputs.nur {
            nurpkgs = pkgs;
            inherit pkgs;
          };
          flake-inputs = inputs;
          inherit vars secrets mkImports;
        }
      ) hosts;
      mkImports =
        scope: imports:
        map (
          modspec:
          let
            mod = if builtins.isPath modspec then import modspec else modspec;
          in
          if builtins.isAttrs mod && builtins.hasAttr scope mod then builtins.getAttr scope mod else mod
        ) imports;
      vars = {
        username = "quentin";
        fullname = "Quentin Inkling";
        theme = "dark";
      };
    in
    configurations
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import inputs.nixpkgs (common-cfg system);
      in
      {
        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}

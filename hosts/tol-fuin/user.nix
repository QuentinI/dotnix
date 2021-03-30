{ config, vars, pkgs, inputs, secrets, ... }:
let
  nur = (import inputs.nur {
    nurpkgs = pkgs;
    pkgs = null;
  });
in {

  home-manager.users."${vars.user}" = { config, pkgs, ... }: {
    imports = [
      nur.repos.rycee.hmModules.theme-base16

      ../../users/modules/profiles/base.nix

      ../../users/modules/services/lorri.nix

      ../../users/modules/programs/zsh
      ../../users/modules/programs/most
      ../../users/modules/programs/nvim
      ../../users/modules/programs/fzf
      ../../users/modules/programs/bat
      ../../users/modules/programs/git

    ];

    theme.base16 = config.lib.theme.base16.fromYamlFile
      "${inputs.base16-nord-scheme}/nord.yaml";

    home = {

      sessionVariables = {
        GOPATH = "$HOME/Code/go";
        PATH = "$HOME/.yarn/bin/:$PATH";
        USE_NIX2_COMMAND = 1;
        EDITOR = "emacs";
        PAGER = "most";
      };

      packages = with pkgs; [
        # Command-line essentials
        binutils
        tmux
        tmate
        atool
        unrar
        unzip
        bzip2
        bat
        exa
        fd
        ripgrep
        htop
        most
        pv
        tldr
        lf
        file
        git
        telnet
        picocom
        gopass
        github-cli
        jq
        rlwrap

        ## Compilers/interpreters
        (python3.withPackages (ps:
          with ps; [
            virtualenv
            pip
            tkinter
            python-language-server
            setuptools
            numpy
            scipy
            matplotlib
            pytest
          ]))
        poetry
        pipenv
        (python2.withPackages (ps: with ps; [ virtualenv pip ]))
        (ghc.withPackages (ps: with ps; [ tidal ]))
        nodejs
        yarn
        rustup
        rust-analyzer
        llvm
        llvmPackages.clang-unwrapped
        elixir
        shellcheck
        nixfmt
        gcc

        jetbrains.jdk # Jetbrains JDK is more convinient generally

        ## Docker
        docker
        docker_compose

        ## Editors and stuff
        irony-server # TODO move to own package with deps

        ntfsprogs
        ntfs3g

        # Nixos housekeeping
        vulnix # NixOS vulnerability scanner
        nox # Apt-cache, kinda
        nix-index
        niv
        nix-diff
        cachix

        # Unsorted. Fuck it.
        # TODO maybe?..
        gnumake
        gnupg
        gnutls
        highlight
        ifuse
        inotify-tools
        jmtpfs
        patchelf
        psmisc
        shared-mime-info

        # Fixes "failed to commit changes to dconf" issues
        gnome3.dconf
      ];
    };

  };
}

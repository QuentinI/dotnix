{ config, vars, pkgs, inputs, ...}:
let 
  nur = (import inputs.nur { nurpkgs = pkgs; pkgs = null; });
  mod = nur.repos.rycee.hmModules.theme-base16;
in
{

  home-manager.users."${vars.user}" = { config, pkgs, ...}: {
    imports = [
      mod

      ../../users/modules/profiles/base.nix

     ../../users/modules/services/lorri.nix
     ../../users/modules/services/kdeconnect.nix
     ../../users/modules/services/gpg-agent.nix
     ../../users/modules/services/shadowsocks.nix
     ../../users/modules/services/nm-applet.nix
     ../../users/modules/services/udiskie.nix
     ../../users/modules/services/memory.nix
     ../../users/modules/services/keybase.nix
     ../../users/modules/services/syncthing.nix
     ../../users/modules/services/jackett.nix
     ../../users/modules/services/sonarr.nix
     ../../users/modules/services/hydroxide.nix

      ../../users/modules/programs/emacs
      ../../users/modules/programs/qutebrowser
      ../../users/modules/programs/browserpass
      ../../users/modules/programs/zsh
      ../../users/modules/programs/most
      ../../users/modules/programs/ncmpcpp
      ../../users/modules/programs/iex
      ../../users/modules/programs/tdesktop
      # ../../users/modules/programs/nvim
      ../../users/modules/programs/kitty
      ../../users/modules/programs/zathura
      ../../users/modules/programs/beets
      ../../users/modules/programs/fzf
      ../../users/modules/programs/bat
      ../../users/modules/programs/git
      ../../users/modules/programs/sway

    ];

    # nixpkgs.config = {
    #   allowUnfree = true;
    #   android_sdk.accept_license = true;
    #   oraclejdk.accept_license = true;
    # };

    theme.base16 = config.lib.theme.base16.fromYamlFile "${inputs.base16-nord-scheme}/nord.yaml";

    gtk = {  
      enable = true;
      iconTheme = {
        name = "Paper";
        package = pkgs.paper-icon-theme;
      };
    };

    home = {

      sessionVariables = {
        GOPATH = "$HOME/Code/go";
        PATH = "$HOME/.yarn/bin/:$PATH";
        USE_NIX2_COMMAND = 1;
        EDITOR = "emacs";
        PAGER = "most";
      };

      keyboard = {
        layout = "us,ru";
        options = [ "grp:caps_toggle" ];
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
        (emacs.override { withXwidgets = true; })
        irony-server # TODO move to own package with deps
        pencil # UML editing
        insomnia # API testing
        postman
        anki

        ## Games
        steam
        xonotic
        wesnoth

        ## Image editing
        imagemagick
        pinta
        krita
        gimp
        ffmpeg

        ## Messaging
        discord
        wire-desktop
        gitter
        zoom-us
        vk-messenger
        skype

        ## Media
        lollypop
        (gnome-podcasts.overrideAttrs (base:
          with pkgs.gst_all_1; {
            buildInputs = base.buildInputs ++ [ gst-plugins-good gst-plugins-ugly ];
          }))
        feh
        mpv
        pulseeffects
        sox
        spotify

        ## Documents
        texlive.combined.scheme-full
        calibre
        zathura
        libreoffice-unwrapped
        pdftk
        pandoc

        ## Browsing
        bitwarden
        firefox
        chromium

        ## Download management
        aria2
        uget
        qbittorrent

        ## Dictionaries
        hunspell
        hunspellDicts.en-us
        aspellDicts.en
        aspellDicts.en-computers
        aspellDicts.en-science
        aspellDicts.ru

        # Screen
        arandr

        # Sound
        pavucontrol
        (speechd.override { withPulse = true; })

        #System management
        anydesk
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
        blueman
        gnumake
        gnupg
        gnutls
        gparted
        highlight
        ifuse
        inotify-tools
        jmtpfs
        networkmanagerapplet
        patchelf
        playerctl
        psmisc
        shared-mime-info
        virtmanager
        stlink # For work

        # Fixes "failed to commit changes to dconf" issues
        gnome3.dconf
      ];
    };

  };
}

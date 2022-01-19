{ config, vars, pkgs, inputs, secrets, ... }:
let
  nur = (import inputs.nur {
    nurpkgs = pkgs;
    pkgs = null;
  });
in {

  home-manager.users."${vars.user}" = { config, pkgs, inputs, ... }: {
    imports = [
      nur.repos.rycee.hmModules.theme-base16

      ../../users/modules/profiles/base.nix
      ../../users/modules/profiles/hdpi.nix

      ../../users/modules/services/lorri.nix
      ../../users/modules/services/kdeconnect.nix
      ../../users/modules/services/gpg-agent.nix
      ../../users/modules/services/shadowsocks.nix
      ../../users/modules/services/nm-applet.nix
      ../../users/modules/services/udiskie.nix
      ../../users/modules/services/memory.nix
      ../../users/modules/services/syncthing.nix
      ../../users/modules/services/jackett.nix
      ../../users/modules/services/sonarr.nix
      ../../users/modules/services/hydroxide.nix

      ../../users/modules/programs/qutebrowser
      ../../users/modules/programs/firefox
      ../../users/modules/programs/zsh
      ../../users/modules/programs/most
      ../../users/modules/programs/ncmpcpp
      ../../users/modules/programs/iex
      ../../users/modules/programs/tdesktop
      ../../users/modules/programs/nvim
      ../../users/modules/programs/kitty
      ../../users/modules/programs/zathura
      ../../users/modules/programs/beets
      ../../users/modules/programs/fzf
      ../../users/modules/programs/bat
      ../../users/modules/programs/git
      ../../users/modules/programs/sway
      ../../users/modules/programs/mpv

    ];

    theme.base16 = config.lib.theme.base16.fromYamlFile
      "${inputs.base16-nord-scheme}/nord.yaml";

    gtk = {
      enable = true;
      iconTheme = {
        name = "Paper${if config.theme.base16.kind == "light" then "-Mono-Dark" else ""}";
        package = pkgs.paper-icon-theme;
      };
      theme = {
        name = "Matcha-${config.theme.base16.kind}-sea";
        package = pkgs.matcha-gtk-theme;
      };
    };

    xdg.configFile."mimeapps.list".force = true;
    xdg.dataFile."applications/mimeapps.list".force = true;
    xdg.mimeApps = {
      enable = true;
      defaultApplications = let
        desktopFile = pkg: name: "${pkg}/share/applications/${name}.desktop";
        firefox = desktopFile pkgs.firefox "firefox";
      in {
        "application/pdf" =
          [ (desktopFile pkgs.zathura "org.pwmt.zathura-pdf-mupdf") ];
        "text/html" = [ firefox ];
        "text/xml" = [ firefox ];
        "application/xhtml+xml" = [ firefox ];
        "application/vnd.mozilla.xul+xml" = [ firefox ];
        "x-scheme-handler/http" = [ firefox ];
        "x-scheme-handler/https" = [ firefox ];
        "x-scheme-handler/ftp" = [ firefox ];
      };
    };

    home = {

      # Hell is other MIME databases
      activation = {
        gioMimes = inputs.home.lib.hm.dag.entryAfter ["writeBoundary"] ''
          ${pkgs.glib}/bin/gio mime 'application/vnd.mozilla.xul+xml' 'firefox.desktop'
          ${pkgs.glib}/bin/gio mime 'application/xhtml+xml' 'firefox.desktop'
          ${pkgs.glib}/bin/gio mime 'text/html' 'firefox.desktop'
          ${pkgs.glib}/bin/gio mime 'text/xml' 'firefox.desktop'
          ${pkgs.glib}/bin/gio mime 'x-scheme-handler/ftp' 'firefox.desktop'
          ${pkgs.glib}/bin/gio mime 'x-scheme-handler/http' 'firefox.desktop'
          ${pkgs.glib}/bin/gio mime 'x-scheme-handler/https' 'firefox.desktop'
        '';
      };

      sessionVariables = {
        GOPATH = "$HOME/Code/go";
        PATH = "$HOME/.yarn/bin/:$HOME/.npm-global:$PATH";
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
            # python-language-server
            setuptools
            numpy
            scipy
            matplotlib
            pytest
            pyserial
            pypdf2
            requests
          ]))
        poetry
        pipenv
        # (python2.withPackages (ps: with ps; [ virtualenv pip ]))
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
        pencil # UML editing
        insomnia # API testing
        postman
        anki
        dbeaver

        ## Games
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
        thunderbird
        slack
        element-desktop

        ## Media
        feh
        # pulseeffects
        sox
        spotify

        ## Documents
        texlive.combined.scheme-full
        zathura
        libreoffice-unwrapped
        pdftk
        pandoc

        ## Browsing
        bitwarden
        ungoogled-chromium

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
        # TODO: broken
        # vulnix # NixOS vulnerability scanner
        nix-index
        niv
        cachix

        # Unsorted. Fuck it.
        # TODO maybe?..
        xh
        duf
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
        rnix-lsp

        # Fixes "failed to commit changes to dconf" issues
        gnome3.dconf

        # Fallback
        gnome.adwaita-icon-theme
      ];
    };

  };
}

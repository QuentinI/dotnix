{ config, vars, pkgs, inputs, secrets, naersk, napalm, ... }:
let
  nur = import inputs.nur {
    nurpkgs = pkgs;
    pkgs = null;
  };

  scr = pkgs.writeShellScriptBin "scr.sh" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    ${pkgs.scrcpy}/bin/scrcpy  -S -K -M -t
  '';

in {

  security.pam.services."${vars.user}".fprintAuth = true;

  services.udev.extraRules = ''
    ACTION=="add", ATTRS{idVendor}=="2717", ATTRS{idProduct}=="ff08", RUN+="${scr}/bin/scr.sh"
  '';

  home-manager.users."${vars.user}" = { config, pkgs, inputs, staging, ... }: {
    imports = [
      nur.repos.rycee.hmModules.theme-base16

      ../../users/modules/profiles/base.nix
      ../../users/modules/profiles/hdpi.nix

      ../../users/modules/services/activitywatch.nix
      ../../users/modules/services/gpg-agent.nix
      ../../users/modules/services/kdeconnect.nix
      ../../users/modules/services/lorri.nix
      ../../users/modules/services/memory.nix
      ../../users/modules/services/nm-applet.nix
      ../../users/modules/services/protonmail-bridge.nix
      ../../users/modules/services/shadowsocks.nix
      ../../users/modules/services/ssh-agent.nix
      ../../users/modules/services/syncthing.nix
      ../../users/modules/services/udiskie.nix

      ../../users/modules/programs/qutebrowser
      ../../users/modules/programs/firefox
      ../../users/modules/programs/zsh
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

    xdg.configFile."hm/theme" = {
        text = vars.theme;
    };

    theme.base16 = config.lib.theme.base16.fromYamlFile
      (if vars.theme == "light"
        then "${inputs.base16-solarized-scheme}/solarized-light.yaml"
        else "${inputs.base16-nord-scheme}/nord.yaml");

    gtk = {
      enable = true;
      iconTheme = {
        name = "Papirus-${
            if config.theme.base16.kind == "light" then "Light" else "Dark"
          }";
        package = pkgs.papirus-icon-theme;
      };
      theme = {
        name = "Canta-${config.theme.base16.kind}";
        package = pkgs.canta-theme;
      };
    };

    qt = {
        platformTheme = "qt5ct";
        style = {
            name = "kvantum";
            package = pkgs.plasma5Packages.qtstyleplugin-kvantum;
        };
    };

    xdg.configFile."mimeapps.list".force = true;
    xdg.dataFile."applications/mimeapps.list".force = true;
    xdg.mimeApps = rec {
      enable = true;
      associations.added = defaultApplications;
      defaultApplications = let
        desktopFiles = pkg: name: [
          "${pkg}/share/applications/${name}.desktop"
          "${name}.desktop"
        ];
        firefox = desktopFiles pkgs.firefox "firefox";
      in {
        "application/pdf" =
          desktopFiles pkgs.zathura "org.pwmt.zathura-pdf-mupdf";
        "text/html" = firefox;
        "text/xml" = firefox;
        "application/xhtml+xml" = firefox;
        "application/vnd.mozilla.xul+xml" = firefox;
        "x-scheme-handler/http" = firefox;
        "x-scheme-handler/https" = firefox;
        "x-scheme-handler/ftp" = firefox;
      };
    };

    home = {

      file."dircolors" = {
        source = "${inputs.nord-dircolors}/src/dir_colors";
        target = ".dir_colors";
      };

      sessionVariables = {
        GOPATH = "$HOME/Code/go";
        PATH = "$HOME/.yarn/bin/:$HOME/.npm-global:$PATH";
        USE_NIX2_COMMAND = 1;
        EDITOR = "nvim";
        PAGER = "more";
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
        pv
        tldr
        lf
        file
        inetutils
        picocom
        pass
        github-cli
        jq
        rlwrap
        gping

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
        (rust-analyzer.override {
          rust-analyzer-unwrapped = rust-analyzer-unwrapped.overrideAttrs
            (old: {
              pname = "rust-analyzer-unwrapped-bumped-recursion";
              patches = [
                (fetchpatch {
                  url =
                    "https://github.com/QuentinI/rust-analyzer/commit/f6fffc019affcf7b0532f6ebb6ca9c0e84a87e93.patch";
                  sha256 =
                    "sha256-ZwQEjKThPO3Wvlt4nVX9qK6qsSKbTICyNICy4niX8Xg=";
                })
              ] ++ old.patches;
            });
        })
        sumneko-lua-language-server
        llvm
        llvmPackages.clang-unwrapped
        elixir
        shellcheck
        nixfmt
        gcc

        jetbrains.jdk # Jetbrains JDK is more convinient generally

        ## Docker
        docker
        docker-compose

        ## Editors and stuff
        irony-server # TODO move to own package with deps

        ## Games
        # Stores/launchers
        steam
        steam-tui
        steam-run-native
        legendary-gl
        heroic
        lutris
        # Native
        xonotic
        wesnoth
        # Wine
        wineWowPackages.waylandFull
        winetricks
        protontricks
        bottles
        # Other
        mangohud

        ## Image editing
        imagemagick
        pinta
        ffmpeg

        ## Messaging
        discord
        thunderbird
        slack
        zoom-us

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
        rnix-lsp
        libsForQt5.qtstyleplugin-kvantum
        gsettings-desktop-schemas
        qt5ct
        notion-app-enhanced

        # Fixes "failed to commit changes to dconf" issues
        dconf

        # Fallback
        gnome.adwaita-icon-theme
      ];
    };

  };
}

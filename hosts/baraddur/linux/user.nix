{
  config,
  vars,
  pkgs,
  secrets,
  napalm,
  nur,
      flake-inputs,
  ...
}:
{
  home-manager.users."${vars.username}" =
    {
      config,
      pkgs,
      inputs,
      staging,
      mkImports,
      ...
    }:
    {
      _module.args = { inherit nur; };

      imports = mkImports "home" [
      #flake-inputs.stylix.homeManagerModules.stylix

         ../../../modules/profiles/base.nix
# ../../../modules/profiles/gaming.nix
         ../../../modules/profiles/hyprland.nix

      ../../../modules/services/gpg-agent.nix
      ../../../modules/services/kdeconnect.nix
      ../../../modules/services/lorri.nix
      ../../../modules/services/memory.nix
      ../../../modules/services/nm-applet.nix
      #../../../modules/services/protonmail-bridge.nix
      ../../../modules/services/shadowsocks.nix
      ../../../modules/services/ssh-agent.nix
      ../../../modules/services/syncthing.nix
      ../../../modules/services/spotifyd.nix
      ../../../modules/services/udiskie.nix

      ../../../modules/programs/firefox
      ../../../modules/programs/zsh
      ../../../modules/programs/ncmpcpp
      ../../../modules/programs/iex
      ../../../modules/programs/tdesktop
      #../../../modules/programs/helix.nix
      ../../../modules/programs/kitty
      ../../../modules/programs/zathura.nix
      ../../../modules/programs/fzf
      ../../../modules/programs/bat.nix
      ../../../modules/programs/git
      ../../../modules/programs/mpv

      ];
      stylix.autoEnable = false;

      services.kanshi.profiles = {
        default = {
          outputs = [
            {
              criteria = "eDP-1";
              position = "0,0";
              scale = 2.0;
            }
          ];
        };
      };

      xdg.configFile."hm/theme" = {
        text = vars.theme;
      };

      gtk = {
        enable = true;
        # iconTheme = {
        #   name = "Papirus-light";
        #   package = pkgs.papirus-icon-theme;
        # };
        theme = {
          name = "Canta-dark";
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
        defaultApplications =
          let
            desktopFiles = pkg: name: [
              "${pkg}/share/applications/${name}.desktop"
              "${name}.desktop"
            ];
            firefox = desktopFiles pkgs.firefox "firefox";
          in
          {
            "application/pdf" = desktopFiles pkgs.zathura "org.pwmt.zathura-pdf-mupdf";
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
          source = "${flake-inputs.nord-dircolors}/src/dir_colors";
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
          ## Compilers/interpreters
          (master.python3.withPackages (
            ps: with ps; [
              virtualenv
              pip
              tkinter
              python-lsp-server
              setuptools
              numpy
              scipy
              matplotlib
              pytest
              pyserial
              pypdf2
              requests
            ]
          ))
          poetry
          pipenv
          # (python2.withPackages (ps: with ps; [ virtualenv pip ]))
          (ghc.withPackages (ps: with ps; [ tidal ]))
          nodejs
          yarn
          rustup
          # rust-analyzer
          sumneko-lua-language-server
          llvm
          llvmPackages.clang-unwrapped
          elixir
          shellcheck
          nixfmt
          gcc
          (mkNeovim {
            inherit pkgs;
	    withLanguageServers = false;
            #theme = config.theme.base16.colors;
          })

          # TODO:
          # jetbrains.jdk # Jetbrains JDK is more convinient generally

          ## Docker
          docker
          docker-compose

          ## Image editing
          imagemagick
          pinta
          ffmpeg

          ## Messaging
          legcord
          thunderbird

          ## Media
          feh
          sox
          # spotify-tui

          ## Documents
          # texlive.combined.scheme-full
          # pdftk
          libreoffice
          zathura
          pandoc

          ## Browsing
          # ungoogled-chromium

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
          vulnix # NixOS vulnerability scanner
          nix-index
          niv
          cachix

          # Unsorted. Fuck it.
          # TODO maybe?..
          blueman
          gnumake
          gnupg
          gnutls
          highlight
          ifuse
          inotify-tools
          jmtpfs
          networkmanagerapplet
          playerctl
          shared-mime-info
          virt-manager
          # rnix-lsp
          libsForQt5.qtstyleplugin-kvantum
          libsForQt5.qt5ct
          gsettings-desktop-schemas
          box64

          # Fixes "failed to commit changes to dconf" issues
          dconf

          # Fallback
          adwaita-icon-theme
        ];
        stateVersion = "22.11";
      };

    };
}

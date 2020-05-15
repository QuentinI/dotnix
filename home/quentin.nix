{ lib, config, pkgs, ... }:

let
  theme = import ./themes { inherit pkgs; };
  stripHash = (s: builtins.substring 1 (-1) s);
in {
  users.defaultUserShell = pkgs.zsh;
  users.users.quentin = {
    createHome = true;
    isNormalUser = true;
    hashedPassword =
      "$6$.KhwDx9tiqA$qH9WXPF/MqdxJluH1q4Puy/pF0tvjbhZ/FPjdsa7gQ4nKhSfdAKgEr4kYW6WOMdtxs8E2sCh3aetu43R06Edf1";
    extraGroups = [
      "libvirtd"
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "docker"
      "dialout"
      "cdrom"
      "wireshark"
    ];
    description = "Quentin Inkling";
  };

  # Workaround by regnat for https://github.com/rycee/home-manager/issues/948
  systemd.services.home-manager-quentin.preStart = ''
    ${pkgs.nix}/bin/nix-env -i -E
  '';

  home-manager.users.quentin = {
    imports = [ ./xsession ./packages ./programs ./services ];

    nixpkgs.config = {
      allowUnfree = true;
      android_sdk.accept_license = true;
      oraclejdk.accept_license = true;
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
    };

    gtk = {
      enable = true;
      iconTheme = {
        name = "Paper";
        package = pkgs.paper-icon-theme;
      };
      theme = rec {
        name = "Materia-Custom";
        package = (pkgs.materia-theme.overrideAttrs (base: rec {
          version = "20200320";

          src = pkgs.fetchFromGitHub {
            owner = "nana-4";
            repo = base.pname;
            rev = "v${version}";
            sha256 = "0g4b7363hzs7z9xghldlz9aakmzzp18hhx32frb6qxy04lna2lwk";
          };

          buildInputs = base.buildInputs
            ++ [ pkgs.sassc pkgs.inkscape pkgs.optipng ];

          installPhase = ''
            patchShebangs *.sh scripts/*.sh src/*/*.sh
            sed -i install.sh \
              -e "s|if .*which gnome-shell.*;|if true;|" \
              -e "s|CURRENT_GS_VERSION=.*$|CURRENT_GS_VERSION=${
                lib.versions.majorMinor pkgs.gnome3.gnome-shell.version
              }|"
            sed -i change_color.sh \
              -e "s|\$HOME/\.themes|$out/share/themes|"
            ./change_color.sh -o '${name}' <(echo -e "BG=${
              stripHash theme.colors.background.primary
            }\n \
                                                         FG=${
                                                           stripHash
                                                           theme.colors.text.primary
                                                         }\n \
                                                         MATERIA_VIEW=${
                                                           stripHash
                                                           theme.colors.background.primary
                                                         }\n \
                                                         MATERIA_SURFACE=${
                                                           stripHash
                                                           theme.colors.background.secondary
                                                         }\n \
                                                         HDR_BG=${
                                                           stripHash
                                                           theme.colors.background.secondary
                                                         }\n \
                                                         HDR_FG=${
                                                           stripHash
                                                           theme.colors.text.primary
                                                         }\n \
                                                         SEL_BG=${
                                                           stripHash
                                                           theme.colors.background.selection
                                                         }\n \
                                                         ROUNDNESS=0\n \
                                                         MATERIA_STYLE_COMPACT=True")
            rm $out/share/themes/*/COPYING
          '';

        }));
      };
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = theme.isDark;
        # gtk-cursor-theme-name = "Paper";
      };
    };

    programs = {
      home-manager.enable = true;
      home-manager.path =
        "https://github.com/rycee/home-manager/archive/master.tar.gz";
    };

    home.extraProfileCommands = ''
      if [[ -d "$out/share/applications" ]] ; then
        ${pkgs.desktop-file-utils}/bin/update-desktop-database $out/share/applications
      fi
    '';
  };
  home-manager.useUserPackages = true;
}

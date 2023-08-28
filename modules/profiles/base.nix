{
  nixos = { pkgs, vars, secrets, inputs, ... }:
    {
      imports = [ ../programs/nix.nix ];

      nixpkgs.config.allowUnfree = true;

      # Doesn't make sense with flakes
      system.autoUpgrade.enable = false;

      users =
        {
          mutableUsers = false;

          users.root = {
            isSystemUser = true;
            group = "root";
            password = null;
            shell = null;
          };

          users."${vars.username}" = {
            createHome = true;
            isNormalUser = true;
            hashedPassword =
              if builtins.hasAttr "user-password" secrets then
                secrets.user-password
              else
                pkgs.lib.warn "Setting empty password for user ${vars.username}!" "";
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
              "uinput"
            ];
            shell = "${pkgs.zsh}/bin/zsh";
            description = vars.fullname;
          };

        };

      # Packages I definitely want on any system
      environment.systemPackages = with pkgs;
        [
          age
          atool
          bat
          binutils
          bzip2
          duf
          exa
          fd
          file
          git
          github-cli
          gping
          htop
          inetutils
          jq
          lf
          neovim
          pass
          patchelf
          picocom
          psmisc
          pv
          ripgrep
          rlwrap
          tldr
          tmate
          tmux
          unrar
          unzip
          usbutils
          xh
        ];

    };

  home = { pkgs, ... }: {
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
}




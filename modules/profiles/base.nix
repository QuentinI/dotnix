let
  defaultPackages = pkgs: [
    # Rust evangelism strike force
    pkgs.bat
    pkgs.duf
    pkgs.fd
    pkgs.ripgrep
    pkgs.xh
    pkgs.eza

    # Archive management
    pkgs.atool
    pkgs.unar
    pkgs.unzip
    pkgs.bzip2

    # Git
    pkgs.git
    pkgs.github-cli

    # Data wrangling
    pkgs.as-tree
    pkgs.jq
    pkgs.dsq
    pkgs.difftastic

    # Multiplexing
    pkgs.zellij
    pkgs.tmate
    pkgs.tmux

    # A little bit of everything
    pkgs.binutils
    pkgs.coreutils
    pkgs.file
    pkgs.age
    pkgs.gping
    pkgs.pass
    pkgs.patchelf
    pkgs.pv
    pkgs.rlwrap
    pkgs.tldr
    pkgs.direnv
    pkgs.progress
    pkgs.htop

    # Languages
    pkgs.nil
    pkgs.go
    pkgs.gopls

    (pkgs.python3.withPackages (ps: [
      ps.llm
      ps.llm-gemini
      ps.llm-jq
      ps.llm-ollama
      ps.llm-cmd
      ps.llm-anthropic
      ps.llm-cerebras
    ]))
  ];
in
{

  darwin =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;
      environment.systemPackages = defaultPackages pkgs;
    };

  nixos =
    {
      pkgs,
      vars,
      secrets,
      ...
    }:
    {
      imports = [ ../programs/nix.nix ];

      nixpkgs.config.allowUnfree = true;
      system.autoUpgrade.enable = false;
      environment.systemPackages = (defaultPackages pkgs) ++ [
        pkgs.busybox
        pkgs.inetutils
        pkgs.usbutils
        pkgs.lshw
        pkgs.htop
        pkgs.psmisc
      ];

      users = {
        mutableUsers = false;

        users.root = {
          isSystemUser = true;
          group = "root";
          password = null;
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
            "render"
          ];
          shell = "${pkgs.zsh}/bin/zsh";
          description = vars.fullname;
        };

      };
    };

  home =
    { pkgs, ... }:
    {
      programs = {
        home-manager.enable = true;
        home-manager.path = "https://github.com/rycee/home-manager/archive/master.tar.gz";
      };

      home.packages = [
        (pkgs.runCommandNoCC "applications-workaround" { } "mkdir -p $out/share/applications")
      ];

      home.extraProfileCommands = ''
        if [[ -d "$out/share/applications" ]] ; then
          ${pkgs.desktop-file-utils}/bin/update-desktop-database $out/share/applications
        fi
      '';
    };

}

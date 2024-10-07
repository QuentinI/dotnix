{
  home = { config, pkgs, system, staging, ... }: {
    home.packages = [ pkgs.delta ];
  
    programs.git = {
      enable = true;
      package = pkgs.git;
      userEmail = "mbee@protonmail.ch";
      userName = "Quentin Inkling";
      signing = {
        signByDefault = true;
        key =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJpRgKD6LSnGjc2lid5nOzdWrst6Ri6mqJ1B3LFQaDzl";
      };
      extraConfig = {
        diff.algorithm = "histogram";
        diff.colorMoved = "default";
        core.pager = "delta";

        interactive.diffFilter = "delta --color-only";
        delta.navigate = true;

        merge.conflictstyle = "diff3";

        filter.lfs = {
          clean = "git-lfs clean -- %f";
          smudge = "git-lfs smudge -- %f";
          process = "git-lfs filter-process";
          required = true;
        };

        gpg.format = "ssh";

	push.autoSetupRemote = true;
      };
    };
  };
}

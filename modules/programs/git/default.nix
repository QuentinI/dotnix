{
  home =
    {
      pkgs, ...
    }:
    {
      home.packages = [ pkgs.delta ];

      programs.git = {
        enable = true;
        package = pkgs.git;
        userEmail = "mbee@protonmail.ch";
        userName = "Quentin Inkling";
        signing = {
          signByDefault = true;
          key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJpRgKD6LSnGjc2lid5nOzdWrst6Ri6mqJ1B3LFQaDzl";
        };
        extraConfig = {
          merge.mergiraf = {
            name = "mergiraf";
            driver = "mergiraf merge --git %O %A %B -s %S -x %X -y %Y -p %P";
          };
          diff.algorithm = "histogram";
          diff.colorMoved = "default";
          core.pager = "delta";
          core.editor = "nvim";

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

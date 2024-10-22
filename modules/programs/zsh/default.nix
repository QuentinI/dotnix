let
  aliases = pkgs: {
    b = "${pkgs.bat}/bin/bat --paging never";
    l = "${pkgs.eza}/bin/eza -lh --git";
    ll = "${pkgs.eza}/bin/eza -lhT --git -L 2";
    lll = "${pkgs.eza}/bin/eza -lhT --git -L 3";
    r = "ranger";
    dc = "docker-compose";
    t = "TERM=xterm"; # Sometimes programs refuse to run in kitty
    "куищще" = "reboot";
  };
  init = pkgs: ''
    source ${pkgs.nix-zsh-completions}/share/zsh/plugins/nix/nix-zsh-completions.plugin.zsh
    fpath=(${pkgs.zsh-completions}/share/zsh/site-functions/ $fpath)
    fpath=(${pkgs.nix-zsh-completions}/share/zsh/site-functions/ $fpath)
    fpath=(${pkgs.nix}/share/zsh/site-functions/ $fpath)

    ${builtins.readFile ./zshrc.zsh}

    if [ -f ~/.dir_colors ]; then
      eval "$(${pkgs.coreutils}/bin/dircolors ~/.dir_colors)";
    else
      eval "$(${pkgs.coreutils}/bin/dircolors)";
    fi

    eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
    export _ZO_ECHO=1
    alias j='z'

    eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
    eval "$(${pkgs.starship}/bin/starship init zsh)"
    eval "$(${pkgs.atuin}/bin/atuin init zsh --disable-up-arrow)"
    source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
    source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh

    _zsh_autosuggest_strategy_atuin() {
      emulate -L zsh
      local prefix="''${1//(#m)[\\*?[\]<>()|^~#]/\\$MATCH}"
      search=$(${pkgs.atuin}/bin/atuin search --cmd-only "^$prefix*" --limit 1)
      typeset -g suggestion=$search
    }

    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
    ZSH_AUTOSUGGEST_STRATEGY=(atuin completion)
    source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  '';
  installed = pkgs: [
    pkgs.atuin
    pkgs.zoxide
    pkgs.starship
    pkgs.direnv
    pkgs.nix-index
  ];
in
{
  darwin =
    { pkgs, ... }:
    {
      programs.zsh = {
        enable = true;
        shellInit = init pkgs;
      };

      environment.shellAliases = aliases pkgs;
      environment.loginShell = "${pkgs.zsh}";
      environment.shells = [ pkgs.zsh ];
    };

  home =
    { pkgs, ... }:
    {
      home.packages = installed pkgs;

      xdg.configFile.starship = {
        target = "starship.toml";
        source = ./starship.toml;
      };

      xdg.configFile.atuin = {
        target = "atuin/config.toml";
        source = ./atuin.toml;
      };

      programs.zsh = {
        enable = true;
        shellAliases = aliases pkgs;
        initExtra = init pkgs;
      };

    };
}

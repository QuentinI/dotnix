{ pkgs, vars, ... }:

{
  fonts.packages = [
    pkgs.font-awesome_4
    pkgs.fira-code-nerdfont
    pkgs.fira-code-symbols
    pkgs.roboto
    pkgs.roboto-slab
    pkgs.roboto-mono
    pkgs.material-icons
  ];

  homebrew = {
    enable = true;
    casks = [
      "clocker"
      "heroic"
      "hammerspoon"
      "thunderbird"
      "goneovim"
      "vimr"
      "protonvpn"
      "syncplay"
      "spaceid"
      "jordanbaird-ice"
    ];
    brews = [
      "gpg"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [
    pkgs.zsh
  ];

  users.users."${vars.username}" = {
    home = "/Users/${vars.username}";
  };

  system.defaults.dock.show-recents = false;
  system.defaults.dock.minimize-to-application = true;
  system.defaults.dock.autohide = true;
  # system.defaults.NSGlobalDomain._HIHideMenuBar = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  security.pam.enableSudoTouchIdAuth = true;

  services.yabai = {
    enable = true;
    enableScriptingAddition = true;
    config = {
      layout = "stack";
      window_shadow = "float";
      window_opacity = "on";
      active_window_opacity = 1.0;
      normal_window_opacity = 0.9;
    };
  };

  services.nix-daemon.enable = true;
  # services.karabiner-elements = {
  #   enable = true;
  # };

  system.stateVersion = 4;
}

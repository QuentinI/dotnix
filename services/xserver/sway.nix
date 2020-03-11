{ config, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.qt5.qtwayland pkgs.sway ];

  programs.sway = {
    enable = true;
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export MOZ_ENABLE_WAYLAND="1"
    '';
  };

  services.xserver = {
    enable = true;
    libinput.enable = true;
    videoDrivers = [ "nouveau" "intel" ];
    displayManager.sddm = {
      enable = true;
      # autoLogin = {
      #   enable = true;
      #   user = "quentin";
      # };
      extraConfig = ''
        [Users]
        HideUsers=jupyter
      '';
    };
    config = "";
    layout = "us,ru";
  };
}

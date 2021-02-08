{ config, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.qt5.qtwayland pkgs.sway ];

  environment.variables = {
    SDL_VIDEODRIVER = "wayland";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    MOZ_ENABLE_WAYLAND = "1";
    _JAVA_AWT_WM_NONREPARENTING="1";
  };

  services.xserver = {
    displayManager = {
      sessionPackages = [ pkgs.sway ];
      defaultSession = "sway";
    };
  };
}

{
  home = _: {
    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
      QT_QPA_PLATFORM = "wayland";
      QT_QPA_PLATFORMTHEME = "qt5ct";
      SDL_VIDEODRIVER = "wayland";
      GDK_BACKEND = "wayland";
      _JAVA_AWT_WM_NONREPARENTING = 1;
      NIXOS_OZONE_WL = 1;
    };

    xdg.configFile.electron = {
      target = "electron-flags.conf";
      text = ''
        --enable-features=UseOzonePlatform
        --ozone-platform=wayland
      '';
    };

    xdg.configFile.chromium = {
      target = "chrome-flags.conf";
      text = ''
        --ozone-platform-hint=auto
      '';
    };
  };
}

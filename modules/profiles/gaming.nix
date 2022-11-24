{
  home = { pkgs, ... }: {
    home.packages = with pkgs; [
      # Stores/launchers
      steam
      steam-tui
      steam-run-native
      legendary-gl
      heroic
      lutris
      # # Native
      xonotic
      wesnoth
      # # Wine
      wineWowPackages.waylandFull
      winetricks
      protontricks
      bottles
      # # Other
      mangohud
    ];
  };
}

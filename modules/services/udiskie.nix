{
  nixos = _: {
    services.udisks2.enable = true;
  };
  home = _: {
    services.udiskie = {
      enable = true;
      automount = true;
      tray = "auto";
    };
  };
}

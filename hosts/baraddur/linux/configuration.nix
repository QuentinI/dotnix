{ pkgs, ... }:

{
  home-manager.useGlobalPkgs = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  system.stateVersion = "22.11";

  time.timeZone = "Europe/Rome";

  services.xserver.displayManager.lightdm.enable = false;
  services.xserver.displayManager.gdm.enable = false;

  services.openssh = {
    enable = true;
  };
  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      userServices = true;
    };
  };

  # TODO: sort out
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    config = {
      preferred = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      };
    };
  };
  services.flatpak.enable = true;
  services.blueman.enable = true;
  networking.wireless.iwd.enable = true;
  # networking.networkmanager.enable = true;
  # networking.networkmanager.wifi.backend = "iwd";
  # networking.networkmanager.wifi.macAddress = "random";
  # networking.networkmanager.unmanaged = [ "interface-name:wl*u*" ]; # Any USB adapters
  networking.firewall.enable = false;
  networking.hostName = "baraddur";
  environment.systemPackages = [
    pkgs.muvm
    pkgs.steam-asahi
    # pkgs.crossSteam.steam
    pkgs.wireguard-tools
    pkgs.glxinfo
  ];
  services.printing.enable = true;
  # sound.enable = true;
  programs.firejail.enable = true;

  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';

  hardware.uinput.enable = true;

  services.xserver.enable = true;
  services.xserver.libinput.enable = true;

  services.colord.enable = true;

  fonts.fonts = with pkgs; [
  nerd-fonts.fira-code
  nerd-fonts.iosevka
    font-awesome_4
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    roboto
    roboto-slab
    roboto-mono
    material-icons
  ];

}

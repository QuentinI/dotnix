inputs@{ config, pkgs, vars, secrets, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  system.stateVersion = "22.11";

  time.timeZone = "Europe/Moscow";

  services.xserver.displayManager.lightdm.enable = false;
  services.xserver.displayManager.gdm.enable = false;

  # TODO: sort out
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };
  services.flatpak.enable = true;
  services.blueman.enable = true;
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.macAddress = "random";
  networking.networkmanager.unmanaged =
    [ "interface-name:wl*u*" ]; # Any USB adapters
  networking.firewall.enable = true;
  networking.hostName = "baraddur";
  services.printing.enable = true;
  sound.enable = true;
  programs.firejail.enable = true;

  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';

  services.xserver.enable = true;
  services.xserver.libinput.enable = true;

  services.colord.enable = true;

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "Iosevka" ]; })
    font-awesome_4
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    roboto
    roboto-slab
    roboto-mono
    material-icons
  ];

}


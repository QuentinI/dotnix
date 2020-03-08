# TODO: this file was once a big blob of everything
# Most of the contents has been factored out,
# but there are still things to do
{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../home/quentin.nix
    ../../services/xserver/i3.nix
    ../../services/jupyter
    ../../services/docker
    ../../services/tor
    ../../services/libvirtd
    ../../services/udev/st-link.nix
    ../../services/zerotierone
  ];

  # Nix-related settings
  system.stateVersion = "19.09";
  nix.autoOptimiseStore = true;
  system.autoUpgrade.enable = true;
  nixpkgs.config.allowUnfree = true;

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Just enable a bunch of stuff
  xdg.portal.enable = true;
  services.flatpak.enable = true;
  services.blueman.enable = true;
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;
  services.printing.enable = true;
  sound.enable = true;
  programs.firejail.enable = true;

  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';

  # Do I really need all these fonts?
  fonts.fonts = with pkgs; [
    font-awesome_4
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    fira-code
    fira-code-symbols
    roboto
    roboto-slab
    roboto-mono
    material-icons
  ];

  # Obscure fixes for something
  systemd.extraConfig = "DefaultLimitNOFILE=1048576";
  security.pam.loginLimits = [{
    domain = "*";
    type = "hard";
    item = "nofile";
    value = "1048576";
  }];
  services.gnome3.at-spi2-core.enable = true;
  services.journald.extraConfig = ''
    SystemMaxUse=16M
  '';

}

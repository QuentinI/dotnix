inputs@{ config, pkgs, vars, secrets, ... }:

{
  users.users."${vars.user}" = {
    createHome = true;
    isNormalUser = true;
    hashedPassword = if builtins.hasAttr "user-password" secrets then
      secrets.user-password
    else
      pkgs.lib.warn "Setting empty password for user ${vars.user}!" "";
    extraGroups = [
      "libvirtd"
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "docker"
      "dialout"
      "cdrom"
      "wireshark"
    ];
    shell = "${pkgs.zsh}/bin/zsh";
    description = "Quentin Inkling";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  system.stateVersion = "21.03";

  services.openvpn.servers = if builtins.hasAttr "vpn" secrets then
    (secrets.vpn inputs)
  else {};

  time.timeZone = "Europe/Moscow";

  # TODO: sort out
  xdg.portal.enable = true;
  services.flatpak.enable = true;
  services.blueman.enable = true;
  networking.networkmanager.enable = true;
  networking.networkmanager.unmanaged = [ "interface-name:wl*u*" ]; # Any USB adapters
  networking.firewall.enable = true;
  networking.hostName = "utumno";
  services.printing.enable = true;
  sound.enable = true;
  programs.firejail.enable = true;

  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';

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

}


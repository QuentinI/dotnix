{ config, pkgs, vars, secrets, ... }:

let
  usb-interface = "enp0s20u3u2";
  eth-interface = "eno2";

in {
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
  boot.blacklistedKernelModules = [ "usb_storage" ];
  system.stateVersion = "21.03";

  time.timeZone = "Europe/Moscow";

  networking.hostName = "tol-fuin";

  networking.firewall.enable = false;
  networking.nat.enable = true;
  networking.nat.externalInterface = usb-interface;
  networking.nat.internalInterfaces = [ eth-interface ];

  networking.dhcpcd = {
    wait = "ipv4";
    extraConfig = ''
      interface ${usb-interface}
      metric 50
    '';
  };

  networking.interfaces."${eth-interface}" = {
    useDHCP = true;
    macAddress = "40:6c:8f:1f:d5:28";
  };
  networking.interfaces."${usb-interface}".useDHCP = true;

  services.dockerRegistry = {
    enable = true;
    listenAddress = "0.0.0.0";
  };

  services.dnsmasq = {
    enable = true;
    servers = [ "1.1.1.1" "8.8.8.8" "91.217.137.37" ];
    extraConfig = ''
      local=/local/
      address=/tol-fuin.local/192.168.10.60
    '';
  };

  services._3proxy = {
    enable = true;
    extraConfig = ''
      log @ H
      logformat L
    '';
    services = [
      {
        type = "socks";
        bindAddress = "192.168.10.60";
        bindPort = 1080;
        auth = [ "none" ];
        maxConnections = 8192;
      }
      {
        type = "proxy";
        bindAddress = "192.168.10.60";
        auth = [ "none" ];
        maxConnections = 8192;
      }
      {
        type = "admin";
        bindAddress = "192.168.10.60";
        bindPort = 1081;
        auth = [ "none" ];
      }
    ];
  };

  systemd.extraConfig = ''
    DefaultLimitDATA=infinity
    DefaultLimitSTACK=infinity
    DefaultLimitCORE=infinity
    DefaultLimitRSS=infinity
    DefaultLimitNOFILE=102400
    DefaultLimitAS=infinity
    DefaultLimitNPROC=10240
    DefaultLimitMEMLOCK=infinity
  '';

}


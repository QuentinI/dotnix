{ lib, modulesPath, inputs, config, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "usb_storage"
    "sdhci_pci"
  ];

  # boot.kernelParams = [ "brcmfmac.feature_disable=0x82000" ];
  boot.kernelPatches = [
    {
      name = "ignore-notch";
      patch = ./ignore-notch.patch;
    }
  ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 1;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFI\\x20-\\x20NIXOS";
    fsType = "vfat";
  };

  fileSystems."/swap" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [
      "subvol=@swap"
    ];
  };

  swapDevices = [
    {
      device = "/swap/swapfile";
    }
  ];


  hardware.asahi = {
    enable = true;
    peripheralFirmwareDirectory = inputs.secrets.m1-firmware;
    useExperimentalGPUDriver = true;
  };
  hardware.graphics.enable = true;


  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
  };

  services.udev.extraRules = ''
    ACTION=="add", KERNEL=="hid_apple", ATTR{parameters/fnmode}="2"
  '';
}

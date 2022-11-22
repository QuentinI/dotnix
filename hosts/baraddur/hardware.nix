# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, inputs, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "usb_storage" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/019b6df2-1bc4-40ec-9a44-1f91c08c4b70";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/22A6-0D1C";
      fsType = "vfat";
    };

  swapDevices = [ ];

  hardware.asahi.peripheralFirmwareDirectory = inputs.secrets.m1-firmware;

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp1s0f0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  # high-resolution display
  hardware.video.hidpi.enable = true;

  hardware.bluetooth.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    media-session = {
      config = {
        bluez-monitor = {
          rules = [{
            # Matches all cards
            matches = [{ "device.name" = "~bluez_card.*"; }];
            actions = {
              "update-props" = {
                "bluez5.msbc-support" = true;
                "bluez5.sbc-xq-support" = true;
              };
            };
          }];
        };
      };
    };
  };
}
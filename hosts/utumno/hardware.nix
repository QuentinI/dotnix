# TODO: this maybe needs to be split into something more modular,
# but I won't probably do it until I have more than one machine
# running NixOS
{ config, lib, pkgs, ... }:

{
  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "usb_storage"
      "usbhid"
      "sd_mod"
      "sr_mod"
      "rtsx_pci_sdmmc"
    ];
    kernelModules = [ "kvm-intel" "nouveau" ];
    extraModulePackages = [ pkgs.xorg.xf86videonouveau ];
    kernelParams = [ "acpi_osi=!" ''acpi_osi="Windows 2009"'' "acpi_backlight=native" "nouveau.modeset=1" ];
    kernel.sysctl = {
      "vm.swappiness" = 0; 
    };

    # Decrypt FDE
    initrd.luks.reusePassphrases = true;
    initrd.luks.devices.root = {
        device = "/dev/disk/by-uuid/c8a132fa-5b19-4168-aff4-7b9b31b58577";
        preLVM = true;
        allowDiscards = true;
    };
    initrd.luks.devices.cryptic_2 = {
        device = "/dev/disk/by-uuid/8174f5ca-3f0c-4c6a-ade0-b37631b88456";
        preLVM = true;
    };

    cleanTmpDir = true;
    tmpOnTmpfs = true;

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.timeout = 2;

    plymouth.enable = true;

  };

  powerManagement.cpuFreqGovernor = "performance";

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/e703ae38-6a84-418a-b91d-e702ff08437c";
      fsType = "btrfs";
      options = [ "discard" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/7643-CB7B";
      fsType = "vfat";
      options = [ "discard" ];
    };

    "/var" = {
      device = "/dev/disk/by-uuid/ec7c1689-178b-4b0e-bbdf-7dca46cab2ee";
      fsType = "btrfs";
      options = [ "noatime" ];
    };
  };

  swapDevices = [{ label = "swap"; }];

  hardware = {
    firmware = [
      pkgs.firmwareLinuxNonfree
    ];
    opengl = {
      enable = true;
      driSupport32Bit = true;
    };
    cpu.intel.updateMicrocode = true;
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      support32Bit = true;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
    };
    bluetooth.enable = true;
    bluetooth.config = {
      General = {
        Enable="Source,Sink,Media,Socket";
      };
    };
    # nvidia = {
    #   prime = {
    #     offload.enable = true;
    #     intelBusId = "PCI:0:2:0";
    #     nvidiaBusId = "PCI:1:0:0";
    #   };
    #   modesetting.enable = true;
    # };
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
    ACTION=="add", SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/leds/%k/brightness"
    ACTION=="add", SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/leds/%k/brightness" 
    ACTION=="add", SUBSYSTEM=="hwmon", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/hwmon/%k/pwm1"
    ACTION=="add", SUBSYSTEM=="hwmon", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/hwmon/%k/pwm1" 
    ACTION=="add", SUBSYSTEM=="hwmon", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/hwmon/%k/pwm1_enable"
    ACTION=="add", SUBSYSTEM=="hwmon", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/hwmon/%k/pwm1_enable" 
  '';

  nix.buildCores = 4;
  nix.maxJobs = lib.mkDefault 4;

  networking.hostName = "utumno"; # Define your hostname.
}

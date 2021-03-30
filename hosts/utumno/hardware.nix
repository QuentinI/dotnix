{ vars, lib, pkgs, ... }:

{
  boot = {
    # nixos-generate-config says i need those
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "usb_storage"
      "usbhid"
      "sd_mod"
      "sr_mod"
      "rtsx_pci_sdmmc"
    ];

    # Graphics card-related
    kernelModules = [ "kvm-intel" "nouveau" "v4l2loopback" ];
    extraModulePackages = [ pkgs.xorg.xf86videonouveau pkgs.linuxPackages.v4l2loopback ];
    kernelParams = [
      "acpi_osi=!"
      ''acpi_osi="Windows 2009"''
      "acpi_backlight=native"
      "nouveau.modeset=1"
    ];

    # I have plenty of RAM and I'd hate to swap to SSD
    kernel.sysctl = {
      "vm.swappiness" = 1; 
    };

    # Don't really remember why I need that
    loader.efi.canTouchEfiVariables = true;
  };

  # Never going achieve good battery life anyway
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

    "/home/${vars.user}/Downloads" = {
      device = "/dev/disk/by-uuid/218772a8-c132-490c-937f-b879ec1a94f1";
      fsType = "btrfs";
      options = [ "defaults" "nodev" "nosuid" "noexec" ];
    };
  };

  swapDevices = [{ label = "swap"; }];

  # FDA
  boot.initrd.luks = {
    reusePassphrases = true;
    devices = {
      root = {
        device = "/dev/disk/by-uuid/c8a132fa-5b19-4168-aff4-7b9b31b58577";
        preLVM = true;
        allowDiscards = true;
      };
      cryptic_2 = {
        device = "/dev/disk/by-uuid/8174f5ca-3f0c-4c6a-ade0-b37631b88456";
        preLVM = true;
      };
    };
  };

  # TODO: this section needs some cleanup
  hardware = {
    firmware = [ pkgs.firmwareLinuxNonfree ];
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = [ pkgs.xorg.xf86videonouveau ];
    };
    cpu.intel.updateMicrocode = true;
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      support32Bit = true;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
    };
    bluetooth.enable = true;
    bluetooth.config = { General = { Enable = "Source,Sink,Media,Socket"; }; };
  };

  nix.buildCores = 4;
  nix.maxJobs = lib.mkDefault 4;

  # Allow user backlight control
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

  # FIXME: Not here
  boot.loader.timeout = 2;
  boot.loader.systemd-boot.enable = true;
  boot.cleanTmpDir = true;
  boot.tmpOnTmpfs = true;
  boot.plymouth.enable = true;

}

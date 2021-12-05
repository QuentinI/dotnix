{ vars, lib, pkgs, ... }:

let nv = pkgs.writeShellScriptBin "nv" ''
  export __NV_PRIME_RENDER_OFFLOAD=1
  export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
  export __GLX_VENDOR_LIBRARY_NAME=nvidia
  export __VK_LAYER_NV_optimus=NVIDIA_only
  exec -a "$0" "$@"
'';
in {
  # hardware.nvidia.modesetting.enable = true;
  environment.systemPackages = [ nv ];
  hardware.nvidia.prime = {
    offload.enable = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
  services.xserver.videoDrivers = [ "nvidia" "intel" ];

  boot = {
    # nixos-generate-config says i need those
    initrd.availableKernelModules = [
      "xhci_pci"
      "thunderbolt"
      "vmd"
      "nvme"
      "usb_storage"
      "sd_mod"
      "usbhid"
      "sd_mod"
      "rtsx_pci_sdmmc"
    ];

    initrd.kernelModules = [ "dm-snapshot" ];

    blacklistedKernelModules = [ "psmouse" ];

    # Graphics card-related
    kernelModules = [ "kvm-intel" "nouveau" "v4l2loopback" ];
    extraModulePackages = [ pkgs.xorg.xf86videonouveau pkgs.linuxPackages.v4l2loopback ];
    kernelParams = [ ];

    # I have plenty of RAM and I'd hate to swap to SSD
    kernel.sysctl = {
      "vm.swappiness" = 1; 
    };

    # Don't really remember why I need that
    loader.efi.canTouchEfiVariables = true;
  };

  powerManagement.cpuFreqGovernor = "powersave";

  fileSystems."/" =
    { device = "/dev/mapper/Cryptic-root";
      fsType = "btrfs";
    };
 
  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/A68D-7FD9";
      fsType = "vfat";
    };

  boot.initrd.luks = {
    devices = {
        root = {
                device = "/dev/disk/by-uuid/a1330fbd-348a-4070-acdb-537c11db98ad";
                preLVM = true;
                allowDiscards = true;
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
    bluetooth.enable = true;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    media-session = {
      config = {
        bluez-monitor = {
          rules = [
            {
              # Matches all cards
              matches = [ { "device.name" = "~bluez_card.*"; } ];
              actions = {
                "update-props" = {
                  "bluez5.msbc-support" = true;
                  "bluez5.sbc-xq-support" = true;
                };
              };
            }
          ];
        };
      };
    };
  };

  services.udev.packages = [ pkgs.light ];

  nix.buildCores = 16;
  nix.maxJobs = lib.mkDefault 16;

  # FIXME: Not here
  boot.loader.timeout = 2;
  boot.loader.systemd-boot.enable = true;
  boot.cleanTmpDir = true;
  boot.tmpOnTmpfs = true;
  boot.plymouth.enable = true;

}

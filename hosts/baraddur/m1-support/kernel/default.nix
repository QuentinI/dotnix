# the Asahi Linux kernel and options that must go along with it

{ config, pkgs, lib, ... }:
{
  config = {
    boot.kernelPackages = config.hardware.asahi.pkgs.callPackage ./package.nix {
      _4KBuild = config.hardware.asahi.use4KPages;
    };

    # we definitely want to use CONFIG_ENERGY_MODEL, and
    # schedutil is a prerequisite for using it
    # source: https://www.kernel.org/doc/html/latest/scheduler/sched-energy.html
    powerManagement.cpuFreqGovernor = lib.mkOverride 800 "schedutil";

    boot.initrd.includeDefaultModules = false;
    boot.initrd.availableKernelModules = [
      # list of initrd modules stolen from
      # https://github.com/AsahiLinux/asahi-scripts/blob/e4d6151a7dcb63ae5e3779c3cf57362eb37d908a/initcpio/install/asahi
      "apple-mailbox"
      "nvme_apple"
      "pinctrl-apple-gpio"
      "macsmc"
      "macsmc-rtkit"
      "i2c-apple"
      "tps6598x"
      "apple-dart"
      "dwc3"
      "dwc3-of-simple"
      "xhci-pci"
      "pcie-apple"
      "gpio_macsmc"
      "spi-apple"
      "spi-hid-apple"
      "spi-hid-apple-of"
      "rtc-macsmc"
      "simple-mfd-spmi"
      "spmi-apple-controller"
      "nvmem_spmi_mfd"
      "apple-dockchannel"
      "dockchannel-hid"
      "apple-rtkit-helper"

      # additional stuff necessary to boot off USB for the installer
      # and if the initrd (i.e. stage 1) goes wrong
      "usb-storage"
      "xhci-plat-hcd"
      "usbhid"
      "hid_generic"
    ];

    boot.kernelParams = [
      "earlycon"
      "console=ttySAC0,1500000"
      "console=tty0"
      "boot.shell_on_fail"
      # Apple's SSDs are slow (~dozens of ms) at processing flush requests which
      # slows down programs that make a lot of fsync calls. This parameter sets
      # a delay in ms before actually flushing so that such requests can be
      # coalesced. Be warned that increasing this parameter above zero (default
      # is 1000) has the potential, though admittedly unlikely, risk of
      # UNBOUNDED data corruption in case of power loss!!!! Don't even think
      # about it on desktops!!
      "nvme_apple.flush_interval=0"
    ];

    # U-Boot does not support EFI variables
    boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

    # GRUB has to be installed as removable if the user chooses to use it
    boot.loader.grub = lib.mkDefault {
      version = 2;
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "nodev";
    };
  };

  imports = [
    (lib.mkRemovedOptionModule [ "boot" "kernelBuildIsCross" ] ''
      If it should still be true (which is unlikely), replace it
      with 'hardware.asahi.pkgsSystem = "x86_64-linux"'. Otherwise, delete it.
    '')

    (lib.mkRemovedOptionModule [ "boot" "kernelBuildIs16K" ] ''
      Replaced with 'hardware.asahi.use4KPages' which defaults to false.
    '')
  ];

  options.hardware.asahi.use4KPages = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Build the Asahi Linux kernel with 4K pages to improve compatibility in
      some cases at the cost of performance in others.
    '';
  };
}

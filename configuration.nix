{ config, pkgs, options, ... }:

let
  sources = import ./nix/sources.nix;
  home-manager = import sources.home-manager {};
  nixpkgs = import sources.nixpkgs {};
in {
  imports = [
    "${sources.nixpkgs}/nixos/modules/profiles/hardened.nix"
    home-manager.nixos
    ./hosts/utumno 
  ];


  boot.initrd.verbose = false;
  boot.consoleLogLevel = 0;
  boot.kernel.sysctl."kernel.dmesg_restrict" = 1;
  boot.kernel.sysctl."printk" = "3 3 3 3";
  boot.kernel.sysctl."dev.tty.ldisc_autoload" = 0;
  boot.kernelParams = ["slab_nomerge" "page_alloc.shuffle=1" "vsyscall=none" "debugfs=off" "quiet" "udev.log_priority=3" "rd.systemd.show_status=auto" ];
  services.resolved.dnssec = "true";
  environment.memoryAllocator.provider = "libc";
  security.allowUserNamespaces = true;

  nix.extraOptions = "experimental-features = nix-command flakes";
  nix.package = pkgs.nixFlakes;

  nix.nixPath = options.nix.nixPath.default
    ++ [ "nixpkgs-overlays=/etc/nixos/overlays/" ];

  nixpkgs.config.allowUnfree = true;

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  i18n.defaultLocale = "en_US.UTF-8";

  home-manager.useUserPackages = true;

  users.mutableUsers = false;
}

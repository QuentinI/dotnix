{
  nixos =
    { pkgs, inputs, ... }:
    {
      imports = [
        "${inputs.nixpkgs}/nixos/modules/profiles/hardened.nix"
      ];

      environment.memoryAllocator.provider = "libc";

      security.apparmor.enable = false;

      services.clamav.daemon.enable = true;
      services.clamav.updater.enable = true;
    };
}

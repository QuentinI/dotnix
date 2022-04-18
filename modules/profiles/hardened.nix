{ pkgs, inputs, ... }:

{
  imports = [
    # "${inputs.nixpkgs}/nixos/modules/profiles/hardened.nix"
    ../services/clamav.nix
  ];

  environment.memoryAllocator.provider = "libc";

  security.apparmor.enable = false;
}

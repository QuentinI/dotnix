{ pkgs, inputs, ...}:

{
  imports = [
    "${inputs.nixos}/nixos/modules/profiles/hardened.nix"
    ../services/clamav.nix
  ];

  environment.memoryAllocator.provider = "libc";  
}

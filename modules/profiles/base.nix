{ inputs, ... }:

{
  imports = [
    ../programs/nix.nix
  ];

  nix.autoOptimiseStore = true;
  users.mutableUsers = false;

  # Doesn't make sense with flakes
  system.autoUpgrade.enable = false;

  users.users.root = {
    isSystemUser = true;
    group = "root";
    password = null;
    shell = null;
  };

}

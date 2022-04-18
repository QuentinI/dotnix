{ secrets, config, pkgs, ... }:

{
  services.zerotierone = {
    enable = true;
    joinNetworks = if builtins.hasAttr "zt-networks" secrets then
      secrets.zt-networks
    else
      [ ];
  };

  nixpkgs.config.allowUnfree = true;
}

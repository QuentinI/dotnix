{ config, pkgs, vars, secrets, ... }:

{
  services.openssh.enable = true;
  users.users."${vars.username}" = {
    openssh.authorizedKeys.keys = secrets.ssh-keys;
  };
}

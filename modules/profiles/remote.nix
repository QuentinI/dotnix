{ config, pkgs, vars, secrets, ... }:

{
  services.openssh.enable = true;
  users.users."${vars.user}" = {
    openssh.authorizedKeys.keys = secrets.ssh-keys;
  };
  # TODO: due to bug in deploy-rs
  security.sudo.wheelNeedsPassword = false;
}

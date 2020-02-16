{ config, pkgs, ...}:

{
  home.packages = [
    pkgs.tdesktop
  ];

  # home.activation.linkTdesktopConfig = config.lib.dag.entryAfter [ "writeBoundary" ] ''
  #   ln -sf $HOME/.config/nixpkgs/programs/tdesktop/settings0 $HOME/.local/share/TelegramDesktop/tdata
  # '';
}

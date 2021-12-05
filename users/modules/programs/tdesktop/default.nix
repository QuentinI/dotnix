{ config, pkgs, ... }:

{
  home.packages = [
    (pkgs.tdesktop.overrideAttrs (old: {
      patches = [ ./fix-ux.patch ];
    })) 
  ];

  xdg.mimeApps = {
    defaultApplications = {
      "x-scheme-handler/tg" = [ "${pkgs.tdesktop}/share/applications/telegramdesktop.desktop" ];
    };
  };

  # home.activation.linkTdesktopConfig = config.lib.dag.entryAfter [ "writeBoundary" ] ''
  #   ln -sf $HOME/.config/nixpkgs/programs/tdesktop/settings0 $HOME/.local/share/TelegramDesktop/tdata
  # '';
}

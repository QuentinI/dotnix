{ config, pkgs, ... }:
let 
  package = pkgs.telegram-desktop.overrideAttrs (old: { patches = old.patches ++ [ ./fix-ux.patch ]; });
in
{
  home.packages = [ package ];

  xdg.mimeApps = {
    defaultApplications = {
      "x-scheme-handler/tg" =
        [ "${package}/share/applications/telegramdesktop.desktop" ];
    };
  };
}

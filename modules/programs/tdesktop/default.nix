{ system, flake-inputs, ... }:
let
  package = flake-inputs.telegram-desktop-patched.packages.${system}.default;
  # pkgs-stable.telegram-desktop.overrideAttrs (old: {
  #   patches = old.patches ++ [ ./fix-ux.patch ];
  # });
in
{
  home.packages = [ package ];

  xdg.mimeApps = {
    defaultApplications = {
      "x-scheme-handler/tg" = [ "${package}/share/applications/telegramdesktop.desktop" ];
    };
  };
}

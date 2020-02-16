{ config, pkgs, ... }:

{
  services.compton = {
    enable = true;
    backend = "xrender";
    package = pkgs.picom;
    vSync = "opengl";
    opacityRule = [ "0:_NET_WM_STATE@:32a *= '_NET_WM_STATE_HIDDEN'" ];
    extraOptions = ''
      detect-client-opacity = true;
      inactive-opacity-override = true;
    '';
  };
}

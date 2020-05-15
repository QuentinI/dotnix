{ lib, pkgs, ... }:

let
  mopidyEnv = pkgs.buildEnv {
    paths = lib.closePropagation [ ];
    name = "mopidy-envt";
    pathsToLink = [ "/${pkgs.python.sitePackages}" ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      makeWrapper ${pkgs.mopidy}/bin/mopidy $out/bin/mopidy \
        --prefix PYTHONPATH : $out/${pkgs.python.sitePackages}
    '';
  };

  startScript = pkgs.writeShellScriptBin "mopidy.sh" ''
    ${mopidyEnv}/bin/mopidy --config ~/.config/mopidy/mopidy.conf
  '';

in {
  home = { packages = [ pkgs.mopidy ]; };

  xdg.configFile.mopidy = {
    text = ''
      [mpd]
      hostname = ::

      [local]
      enabled = true
      library = json
      media_dir = ~/Music
    '';
    target = "mopidy/mopidy.conf";
  };

  systemd.user.services.mopidy = {
    Install = { WantedBy = [ "graphical-session.target" ]; };
    Service = {
      ExecStart = "${startScript}/bin/mopidy.sh";
      Restart = "on-abort";
    };
  };
}

{ config, lib, pkgs, ... }:

let

  mopidyEnv = pkgs.buildEnv {
    name = "mopidy-with-extensions-${pkgs.mopidy.version}";
    paths = lib.closePropagation [
      pkgs.glib-networking
      pkgs.gobject-introspection
      pkgs.mopidy
      pkgs.mopidy-mpd
      pkgs.mopidy-spotify
      pkgs.mopidy-iris
      (import ./mopidy-local.nix { inherit config pkgs; })
    ];
    pathsToLink = [ "/${pkgs.mopidyPackages.python.sitePackages}" ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      makeWrapper ${pkgs.mopidy}/bin/mopidy $out/bin/mopidy \
        --prefix PYTHONPATH : $out/${pkgs.mopidyPackages.python.sitePackages}
    '';
  };

  startScript = pkgs.writeShellScriptBin "mopidy.sh" ''
    ${mopidyEnv}/bin/mopidy --config ~/.config/mopidy/mopidy.conf \
      -o spotify/username=quentini@airmail.cc \
      -o spotify/password=$(sed '1q;d' <(${pkgs.pass}/bin/pass show spotify.com/quentini@airmail.cc)) \
      -o spotify/client_id=$(sed '2q;d' <(${pkgs.pass}/bin/pass show spotify.com/quentini@airmail.cc)) \
      -o spotify/client_secret=$(sed '2q;d' <(${pkgs.pass}/bin/pass show spotify.com/quentini@airmail.cc)) \
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
      [iris]
      country = us
      locale = en_US
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

{ pkgs, ... }:

{
  programs = {
    home-manager.enable = true;
    home-manager.path =
      "https://github.com/rycee/home-manager/archive/master.tar.gz";
  };

  home.extraProfileCommands = ''
    if [[ -d "$out/share/applications" ]] ; then
      ${pkgs.desktop-file-utils}/bin/update-desktop-database $out/share/applications
    fi
  '';
}

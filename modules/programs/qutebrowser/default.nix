{ config, pkgs, ... }:

let
  profile = pkgs.writeText "qutebrowser" ''
    include qutebrowser.profile

    noblacklist ''${PATH}/bw
  '';
  jailed = pkgs.runCommand "qutebrowser" {
    preferLocalBuild = true;
    allowSubstitutes = false;
  } ''
    mkdir -p $out/bin
    cat <<_EOF >$out/bin/qutebrowser
    #! ${pkgs.runtimeShell} -e
    exec firejail --profile=${profile} -- ${pkgs.qutebrowser}/bin/qutebrowser "\$@"
    _EOF
    chmod 0755 $out/bin/qutebrowser
  '';

in {
  home.packages = [
    pkgs.firejail
    jailed
    pkgs.bitwarden-cli
    pkgs.keyutils # For bitwarden userscript
  ];
}

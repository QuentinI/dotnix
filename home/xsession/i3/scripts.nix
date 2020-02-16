{ config, pkgs, ...}:

let
  interpreter = (pkgs.python3.buildEnv.override {
    extraLibs = with pkgs.python3Packages; [ i3ipc mpd2 requests pillow numpy scipy ];
    ignoreCollisions = true;
  }).interpreter;
  script = builtins.readFile ./script.py;
  scriptWrapper = pkgs.writeShellScriptBin "i3py_script.sh" ''
    ${config.xdg.configHome}/i3/scripts/main.py $(${pkgs.i3}/bin/i3 --get-socketpath)
  '';
in
rec {
  xdg.configFile.i3py_script = {
    executable = true;
    target     = "i3/scripts/main.py";
    text       = "#!${interpreter}\n${script}";
  };

  systemd.user.services.i3py_script = {
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${scriptWrapper}/bin/i3py_script.sh";
      Restart = "always";
    };
  };
}

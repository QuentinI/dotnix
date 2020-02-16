{ config, pkgs, ... }:

let
  startScript = pkgs.writeShellScriptBin "memory.sh" ''
    AWK=${pkgs.gawk}/bin/awk
    FREE=${pkgs.procps}/bin/free
    NOTIFY=${pkgs.notify-desktop}/bin/notify-desktop
    SLEEP=${pkgs.coreutils}/bin/sleep
    HIGH=false
    LAST=false
    NORMAL_SECONDS=0
    LOW_SECONDS=0

    while :
    do
      MEM_PERCENT=$($FREE | $AWK 'FNR == 2 {print int($3/($3+$7)*100) }')
      if [ "$MEM_PERCENT" -gt 80 ]; then
        if [ "$LAST" = false ]; then
           if [ "$LOW_SECONDS" = 0 ]; then
              $NOTIFY "Memory low!" "Current usage is $MEM_PERCENT%" -u critical -r 16492;
              LAST=true;
              LOW_SECONDS=20;
           fi
        fi
      else
        if [ "$LAST" = true ]; then
           if [ "$NORMAL_SECONDS" = 0 ]; then
              $NOTIFY "Memory usage back to normal" "Current usage is $MEM_PERCENT%" -r 16492;
              LAST=false;
              NORMAL_SECONDS=20;
           fi
        fi
      fi
      if [ "$LOW_SECONDS" -ne 0 ]; then
         LOW_SECONDS=$(expr $LOW_SECONDS - 1);
      fi
      if [ "$NORMAL_SECONDS" -ne 0 ]; then
         NORMAL_SECONDS=$(expr $NORMAL_SECONDS - 1);
      fi
      $SLEEP 1
    done
  '';
in

{
  home.packages = with pkgs; [ gawk procps notify-desktop ];
  systemd.user.services.memory = {
      Install = {
          WantedBy = [ "graphical-session.target" ];
      };
      Service = {
          ExecStart = "${startScript}/bin/memory.sh";
          Restart = "on-abort";
      };
  };
}

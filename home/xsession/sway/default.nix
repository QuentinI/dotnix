{ config, pkgs, ... }:

let
  modifier = "Mod4";
  theme = import ../../themes { inherit pkgs; };
  mkOpaque = import ../../themes/lib/mkOpaque.nix;
  waybar = (pkgs.waybar.override {
    pulseSupport = true;
    traySupport = true;
  });

  # TODO
  lock = pkgs.writeShellScriptBin "lock.sh" ''
    ${pkgs.grim}/bin/grim /tmp/lock_screenshot.jpg
    ${pkgs.imagemagick}/bin/convert /tmp/lock_screenshot.jpg -filter point -resize 10% -resize 1000% /tmp/lock_screenshot.png
    ${pkgs.swaylock}/bin/swaylock -i /tmp/lock_screenshot.png -e -f
  '';

  # TODO
  graphical_resize = pkgs.writeShellScriptBin "resize.sh" ''
    SLURP=${pkgs.slurp}/bin/slurp
    SWAYMSG=${pkgs.sway}/bin/swaymsg

    $SWAYMSG mark __moving

    read -r X Y W H G ID < <($SLURP -b '#ffffff00' -c '${theme.colors.background.accent}ff' -f '%x %y %w %h %g %i')

    if [ -z "$X" ]; then
      $SWAYMSG unmark __moving
      exit;
    fi;

    $SWAYMSG [con_mark="__moving"] floating enable
    $SWAYMSG [con_mark="__moving"] move position $X $Y

    if [ "$W" -eq "0" ]; then
      $SWAYMSG unmark __moving
      exit;
    fi;

    $SWAYMSG [con_mark="__moving"] resize set $W $H
    $SWAYMSG unmark __moving
  '';

  mpdByTitle = pkgs.writeShellScriptBin "mpdByTitle.sh" ''

    JQ=${pkgs.jq}/bin/jq
    MPC=${pkgs.mpc_cli}/bin/mpc

    # function by Fikri Omar
    # https://github.com/fikriomar16/rofi-mpd/blob/master/rofi-mpd
    addaftercurrentandplay(){

          #playlist is empty, just add the song
          if [ "$($MPC playlist | wc -l)" == "0" ]; then
                  $MPC add "$1"
                  sleep 0.3
                  $MPC play

          #there is no current song so mpd is stopped
          #it seems to be impossible to determine the current songs' position when 
          #mpd is stopped, so just add to the end
          elif [ -z "$($MPC current)" ]; then 
                  END_POS=$($MPC playlist | wc -l)
                  $MPC add "$1"
                  sleep 0.3
                  $MPC play $(($END_POS+1))

          #at least 1 song is in the playlist, determine the position of the 
          #currently played song and add $1 after it
          else
                  CUR_POS=$($MPC | tail -2 | head -1 | awk '{print $2}' | sed 's/#//' | awk -F/ '{print $1}')
                  END_POS=$($MPC playlist | wc -l)
                  $MPC add "$1"
                  sleep 0.3
                  $MPC move $(($END_POS+1)) $(($CUR_POS+1))
                  sleep 0.3
                  $MPC play $(($CUR_POS+1))
          fi
    }

    addalbum() {
      titles=("$@")
      IFS=$'\n' sorted=($(sort <<<"${"$"}{titles[*]}"))
      unset IFS
      addaftercurrentandplay ${"$"}{sorted[0]};
      COUNT=0;
      CUR_POS=$($MPC | tail -2 | head -1 | awk '{print $2}' | sed 's/#//' | awk -F/ '{print $1}')
      for i in "${"$"}{sorted[@]:1}"
      do
        END_POS=$($MPC playlist | wc -l)
        $MPC add "$i"
        sleep 0.3
        $MPC move $(($END_POS+1)) $(($CUR_POS+1+$COUNT))
        sleep 0.3
        COUNT=$(($COUNT+1))
      done
    }

    case $1 in
      track)
        title=$(gzip -d -c ~/.local/share/mopidy/local/library.json.gz | $JQ -r ".tracks[] | .name + \" <small>(\"  + .artists[0].name + \", \" + .album.name + \")</small>\" " | sort | rofi -dmenu -markup-rows -matching normal -i | sed 's/<small>.*//' | xargs -I % $MPC find Title "%" | cut -d " " -f1)
        if [ "$title" ]; then
          addaftercurrentandplay $title;
        fi
        ;;
      album)
        titles=$(gzip -d -c ~/.local/share/mopidy/local/library.json.gz | $JQ -r ".tracks[].album | .name + \" <small>(\" + .artists[0].name + \")</small>\"" | sort | uniq | rofi -dmenu -markup-rows -matching normal -i | sed 's/<small>.*//' | xargs -I % $MPC find Album "%")
        if [ "$titles" ]; then
          addalbum $titles;
        fi
        ;;
      *)
    esac

  '';

in rec {
  imports = [ ../../programs/rofi ../../services/mako ];

  home.packages = [
    pkgs.sway
    pkgs.swaylock
    pkgs.grim
    pkgs.slurp
    pkgs.wl-clipboard
    pkgs.pamixer
    pkgs.wob
    pkgs.light
    waybar
    pkgs.libappindicator
  ];

  # Get rid of Qt filepickers, etc
  home.sessionVariables = { "XDG_CURRENT_DESKTOP" = "XFCE"; };

  # Waybar works with libappindicator tray icons only
  xsession.preferStatusNotifierItems = true;

  # TODO:
  # xdg.configFile.dunst_volume = {
  # };

  xdg.configFile.waybar_config = {
    source = ./waybar_config.json;
    target = "waybar/config";
  };

  # TODO: figure out how to use variables in GTK CSS
  xdg.configFile.waybar_style = {
    text = ''
      * {
          border: none;
          border-radius: 0;
          font-family: Fira Code;
          font-size: 16px;
          min-height: 0;
      }

      window#waybar {
          background-color: ${theme.colors.background.primary};
          color: ${theme.colors.text.primary};
          transition-property: background-color;
          transition-duration: .5s;
      }

      window#waybar.hidden {
          opacity: 0.2;
      }

      #workspaces button {
          border-bottom: 3px solid ${theme.colors.background.primary};
          padding: 0;
          margin: 0;
      }

      #workspaces button.urgent {
          background-color: ${theme.colors.background.urgent};
      }

      #workspaces button.focused {
          border-bottom: 3px solid ${theme.colors.background.accent};
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #temperature,
      #backlight,
      #network,
      #pulseaudio,
      #custom-media,
      #tray,
      #mode,
      #idle_inhibitor,
      #mpd {
          padding: 0 7px;
      }

      #battery.charging {
          color: #26A65B;
      }

      #battery.critical:not(.charging) {
          background-color: ${theme.colors.background.urgent};
      }

      #pulseaudio.muted {
          color: ${theme.colors.text.disabled};
      }
    '';
    target = "waybar/style.css";
  };

  wayland.windowManager.sway.enable = true;
  wayland.windowManager.sway.config = {
    assigns = {
      "1" = [
        { class = "Firefox"; }
        { class = "Chromium-browser"; }
        { class = "Deluge"; }
      ];
      "2" =
        [ { title = "Atom"; } { class = "jetbrains"; } { class = "Emacs"; } ];
      "3" = [
        { class = "TelegramDesktop"; }
        { class = "discord"; }
        { class = "Keybase"; }
        { class = "Daily"; }
      ];
      "5" = [
        { class = "Steam"; }
        { class = "wesnoth"; }
        { class = "xonotic-(glx|sdl)"; }
      ];
    };

    bars = [{
      command = "${waybar}/bin/waybar";
      position = "bottom";
    }];

    colors = rec {
      focused = {
        background = theme.colors.background.primary;
        border = theme.colors.background.primary;
        childBorder = theme.colors.background.accent;
        indicator = "#2e9ef4"; # TODO
        text = theme.colors.text.primary;
      };
      focusedInactive = {
        background = mkOpaque theme.colors.background.primary;
        border = mkOpaque theme.colors.background.primary;
        childBorder = mkOpaque theme.colors.background.primary;
        indicator = "#484e50";
        text = theme.colors.text.primary;
      };
      placeholder = {
        background = "#0000005a";
        border = "#0000005a";
        childBorder = "#0c0c0c";
        indicator = "#000000";
        text = "#ffffff";
      };
      unfocused = {
        background = mkOpaque theme.colors.background.secondary;
        border = mkOpaque theme.colors.background.secondary;
        childBorder = theme.colors.background.primary;
        indicator = "#484e50";
        text = theme.colors.text.primary;
      };
      urgent = placeholder;
    };

    modifier = modifier;
    floating.modifier = modifier;

    gaps = {
      inner = 10;
      smartGaps = true;
      smartBorders = "on";
    };

    fonts = [ "Fira Code 10" ];

    keybindings = { };

    modes = {
      resize = {
        h = "resize shrink width 10 px or 10 ppt";
        j = "resize grow height 10 px or 10 ppt";
        k = "resize shrink height 10 px or 10 ppt";
        l = "resize grow width 10 px or 10 ppt";
        Return = "mode default";
        Escape = "mode default";
      };
    };

    input = {
      "type:keyboard" = {
        xkb_options = "grp:caps_toggle";
        xkb_layout = "us,ru";
      };
      "type:touchpad" = {
        click_method = "clickfinger";
        natural_scroll = "enabled";
        tap = "enabled";
      };
    };
  };
  wayland.windowManager.sway.extraConfig = ''
    focus_wrapping workspace
    exec mkfifo $SWAYSOCK.wob && tail -f $SWAYSOCK.wob | ${pkgs.wob}/bin/wob -a bottom -M 40 -t 500

    # I'm looking at you, telegram
    for_window [title="Choose files"] floating enable
    for_window [title="Choose files"] resize width 900 height 550
    for_window [title="Choose files"] move center

    bindsym --to-code ${modifier}+Shift+q kill

    bindsym --to-code ${modifier}+h           focus left
    bindsym --to-code ${modifier}+j           focus down
    bindsym --to-code ${modifier}+k           focus up
    bindsym --to-code ${modifier}+l           focus right
    bindsym --to-code ${modifier}+r           exec ${graphical_resize}/bin/resize.sh
    bindsym ${modifier}+Tab                   focus right
    bindsym ${modifier}+Shift+Tab             focus left
    bindsym --to-code ${modifier}+Shift+h     move left
    bindsym --to-code ${modifier}+Shift+j     move down
    bindsym --to-code ${modifier}+Shift+k     move up
    bindsym --to-code ${modifier}+Shift+l     move right

    bindsym ${modifier}+1           workspace 1
    bindsym ${modifier}+2           workspace 2
    bindsym ${modifier}+3           workspace 3
    bindsym ${modifier}+4           workspace 4
    bindsym ${modifier}+5           workspace 5
    bindsym ${modifier}+6           workspace 6
    bindsym ${modifier}+grave       workspace 7
    bindsym ${modifier}+Shift+1     move container to workspace 1
    bindsym ${modifier}+Shift+2     move container to workspace 2
    bindsym ${modifier}+Shift+3     move container to workspace 3
    bindsym ${modifier}+Shift+4     move container to workspace 4
    bindsym ${modifier}+Shift+5     move container to workspace 5
    bindsym ${modifier}+Shift+6     move container to workspace 6
    bindsym ${modifier}+Shift+grave move container to workspace 7

    bindsym --to-code ${modifier}+n           exec telegram-desktop; exec Discord; exec vk; exec thunderbird; exec skypeforlinux; exec wire-desktop
    bindsym --to-code ${modifier}+f           exec kitty -T=lf lf
    bindsym --to-code ${modifier}+w           layout tabbed
    bindsym --to-code ${modifier}+e           layout toggle split
    bindsym ${modifier}+Shift+space           floating toggle
    bindsym --to-code ${modifier}+s           sticky toggle

    bindsym --to-code ${modifier}+Shift+c     reload
    bindsym --to-code ${modifier}+Shift+r     restart
    bindsym --to-code ${modifier}+Shift+e     exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'

    bindsym ${modifier}+Return      exec kitty
    bindsym Menu                    exec rofi -show

    bindsym Print                      exec grim ~/Pictures/screenshots/$(date +\"%Y-%m-%d_%H:%M:%S\").png
    bindsym Control+Print              exec grim - | wl-copy -p -o -t image/png
    bindsym ${modifier}+Print          exec grim -g "$(slurp -b '#ffffff00' -c '${theme.colors.background.accent}ff')" ~/Pictures/screenshots/$(date +\"%Y-%m-%d_%H:%M:%S\").png
    bindsym ${modifier}+Control+Print  exec grim -g "$(slurp -b '#ffffff00' -c '${theme.colors.background.accent}ff')" - | wl-copy -p -o -t image/png

    bindsym XF86KbdBrightnessUp     exec ${pkgs.light}/bin/light -s sysfs/leds/asus::kbd_backlight -A 1 && ${pkgs.light}/bin/light -s sysfs/leds/asus::kbd_backlight -G | cut -d'.' -f1 > $SWAYSOCK.wob
    bindsym XF86KbdBrightnessDown   exec ${pkgs.light}/bin/light -s sysfs/leds/asus::kbd_backlight -U 1 && ${pkgs.light}/bin/light -s sysfs/leds/asus::kbd_backlight -G | cut -d'.' -f1 > $SWAYSOCK.wob

    bindsym ${modifier}+F3          exec echo $(expr $(cat /sys/devices/platform/asus-nb-wmi/hwmon/hwmon3/pwm1) - 3) > /sys/devices/platform/asus-nb-wmi/hwmon/hwmon3/pwm1
    bindsym ${modifier}+F4          exec echo $(expr $(cat /sys/devices/platform/asus-nb-wmi/hwmon/hwmon3/pwm1) + 3) > /sys/devices/platform/asus-nb-wmi/hwmon/hwmon3/pwm1
    bindsym ${modifier}+F2          exec echo $([[ $(cat /sys/devices/platform/asus-nb-wmi/hwmon/hwmon3/pwm1_enable) = 2 ]] && echo 1 || echo 2) > /sys/devices/platform/asus-nb-wmi/hwmon/hwmon3/pwm1_enable

    bindsym XF86AudioRaiseVolume    exec ${pkgs.pamixer}/bin/pamixer -ui 2 && ${pkgs.pamixer}/bin/pamixer --get-volume > $SWAYSOCK.wob
    bindsym XF86AudioLowerVolume    exec ${pkgs.pamixer}/bin/pamixer -ud 2 && ${pkgs.pamixer}/bin/pamixer --get-volume > $SWAYSOCK.wob
    bindsym XF86AudioMute           exec ${pkgs.pamixer}/bin/pamixer --toggle-mute && ( ${pkgs.pamixer}/bin/pamixer --get-mute && echo 0 > $SWAYSOCK.wob ) || ${pkgs.pamixer}/bin/pamixer --get-volume > $SWAYSOCK.wob

    bindsym XF86MonBrightnessUp     exec ${pkgs.light}/bin/light -A 3 && ${pkgs.light}/bin/light -G | cut -d'.' -f1 > $SWAYSOCK.wob
    bindsym XF86MonBrightnessDown   exec ${pkgs.light}/bin/light -U 3 && ${pkgs.light}/bin/light -G | cut -d'.' -f1 > $SWAYSOCK.wob

    bindsym ${modifier}+F5  opacity minus 0.05
    bindsym ${modifier}+F6  opacity plus  0.05

    bindsym XF86PowerOff            exec ${lock}/bin/lock.sh


    bindsym ${modifier}+F11         fullscreen

    bindsym --to-code ${modifier}+m           exec ${mpdByTitle}/bin/mpdByTitle.sh track
    bindsym --to-code ${modifier}+a           exec ${mpdByTitle}/bin/mpdByTitle.sh album

    bindsym --to-code Control+Space       exec ${pkgs.mako}/bin/makoctl dismiss
    bindsym --to-code Control+Shift+Space exec ${pkgs.mako}/bin/makoctl dismiss -a
  '';
}

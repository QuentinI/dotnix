{
  config,
  pkgs,
  mkImports,
  ...
}:

let
  modifier = "Mod4";
  # mkOpaque = import ../../themes/lib/mkOpaque.nix;
  mkOpaque = x: x;

  # TODO
  lock = pkgs.writeShellScriptBin "lock.sh" ''
    outputs=($(swaymsg -t get_outputs | jq -r '.[]'.name));
    arguments=()
    for output in "''${outputs[@]}"; do
      basename="/tmp/''${output}_lock_screenshot"
      ${pkgs.grim}/bin/grim -o "$output" "$basename.jpg";
      ${pkgs.imagemagick}/bin/convert "$basename.jpg" -filter point -resize 10% -resize 1000% "$basename.png";
      arguments+=("-i")
      arguments+=("$output:$basename.png")
    done

    ${pkgs.swaylock}/bin/swaylock ''${arguments[@]} -e -f;
  '';

  # TODO
  graphical_resize = pkgs.writeShellScriptBin "resize.sh" ''
    SLURP=${pkgs.slurp}/bin/slurp
    SWAYMSG=swaymsg

    $SWAYMSG mark __moving

    read -r X Y W H G ID < <($SLURP -b '#ffffff00' -c '#${config.lib.stylix.colors.base05}ff' -f '%x %y %w %h %g %i')

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

in {
  imports = mkImports "home" [
    ./waybar
    ../wayland.nix
    ../../programs/rofi.nix
    ../../services/mako.nix
  ];

  home.packages = [
    pkgs.swaylock
    pkgs.grim
    pkgs.slurp
    pkgs.wl-clipboard
    pkgs.pamixer
    pkgs.wob
    pkgs.light
    pkgs.libappindicator
    pkgs.playerctl
    pkgs.xdg-desktop-portal-wlr
    pkgs.kanshi
  ];

  services.kanshi = {
    enable = true;
    profiles = pkgs.lib.mkDefault (pkgs.lib.warn "Sway is enabled, but no kanshi profiles are set" { });
  };

  wayland.windowManager.sway.enable = true;
  wayland.windowManager.sway.extraOptions = [
    "--unsupported-gpu"
    "--verbose"
  ];
  wayland.windowManager.sway.config = {
    assigns = {
      "1" = [
        { app_id = "firefox"; }
        { class = "Chromium-browser"; }
        { class = "Deluge"; }
      ];
      "2" = [
        { title = "Atom"; }
        { class = "jetbrains"; }
        { class = "Emacs"; }
      ];
      "3" = [
        { app_id = "telegramdesktop"; }
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

    # colors = rec {
    #   focused = {
    #     background = "#${config.theme.base16.colors.base00.hex.rgb}";
    #     border = "#${config.theme.base16.colors.base00.hex.rgb}";
    #     childBorder = "#${config.theme.base16.colors.base06.hex.rgb}";
    #     indicator = "#2e9ef4"; # TODO
    #     text = "#${config.theme.base16.colors.base04.hex.rgb}";
    #   };
    #   focusedInactive = {
    #     background = mkOpaque "#${config.theme.base16.colors.base00.hex.rgb}";
    #     border = mkOpaque "#${config.theme.base16.colors.base00.hex.rgb}";
    #     childBorder = mkOpaque "#${config.theme.base16.colors.base00.hex.rgb}";
    #     indicator = "#484e50";
    #     text = "#${config.theme.base16.colors.base04.hex.rgb}";
    #   };
    #   placeholder = {
    #     background = "#0000005a";
    #     border = "#0000005a";
    #     childBorder = "#0c0c0c";
    #     indicator = "#000000";
    #     text = "#ffffff";
    #   };
    #   unfocused = {
    #     background = mkOpaque "#${config.theme.base16.colors.base01.hex.rgb}";
    #     border = mkOpaque "#${config.theme.base16.colors.base01.hex.rgb}";
    #     childBorder = "#${config.theme.base16.colors.base00.hex.rgb}";
    #     indicator = "#484e50";
    #     text = "#${config.theme.base16.colors.base04.hex.rgb}";
    #   };
    #   urgent = placeholder;
    # };

    inherit modifier;
    floating.modifier = modifier;

    gaps = {
      inner = 10;
      smartGaps = true;
      smartBorders = "on";
    };

    fonts = {
      names = [ "Fira Code 10" ];
    };

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

    output = {
      "*" = {
        background = "#${config.lib.stylix.colors.base00} solid_color";
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
        dwt = "enabled";
      };
    };
  };

  wayland.windowManager.sway.extraConfig = ''
    hide_edge_borders none --i3
    focus_wrapping workspace
    exec mkfifo $SWAYSOCK.wob && tail -f $SWAYSOCK.wob | ${pkgs.wob}/bin/wob -a bottom -M 40 -t 500

    # I'm looking at you, telegram
    for_window [title="Choose files"] floating enable
    for_window [title="Choose files"] resize width 900 height 550
    for_window [title="Choose files"] move center

    bindsym --to-code ${modifier}+Shift+q kill

    bindsym --to-code ${modifier}+x splith

    bindsym --to-code ${modifier}+d       move window to scratchpad
    bindsym --to-code ${modifier}+Shift+d scratchpad show

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

    bindsym --to-code ${modifier}+m           layout splith; exec telegram-desktop; exec slack; exec thunderbird
    bindsym --to-code ${modifier}+f           exec LIBGL_ALWAYS_SOFTWARE=true kitty -T=lf lf
    bindsym --to-code ${modifier}+w           layout tabbed
    bindsym --to-code ${modifier}+e           layout toggle split
    bindsym ${modifier}+Shift+space           floating toggle
    bindsym --to-code ${modifier}+s           sticky toggle
    bindsym --to-code ${modifier}+g           gaps inner current set 0
    bindsym --to-code ${modifier}+Shift+g     gaps inner current set 10

    bindsym --to-code ${modifier}+Shift+c     reload
    bindsym --to-code ${modifier}+Shift+r     restart
    bindsym --to-code ${modifier}+Shift+e     exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'

    bindsym ${modifier}+Return      exec LIBGL_ALWAYS_SOFTWARE=true kitty
    bindsym ${modifier}+Shift+Return      exec konsole
    bindsym ${modifier}+Menu        exec rofi -show drun -display-drun 'run'
    bindsym ${modifier}+Space       exec rofi -show drun -display-drun 'run'
    bindsym Control_R               exec rofi -show drun -display-drun 'run'

    bindsym XF86LaunchA                      exec grim ~/Pictures/Screenshots/$(date +\"%Y-%m-%d_%H:%M:%S\").png
    bindsym Control+XF86LaunchA              exec grim - | wl-copy -p -o -t image/png
    bindsym ${modifier}+XF86LaunchA          exec grim -g "$(slurp -b '#ffffff00' -c '#${config.lib.stylix.colors.base06}ff')" ~/Pictures/Screenshots/$(date +\"%Y-%m-%d_%H:%M:%S\").png
    bindsym ${modifier}+Control+XF86LaunchA  exec grim -g "$(slurp -b '#ffffff00' -c '#${config.lib.stylix.colors.base06}ff')" - | wl-copy -p -o -t image/png

    bindsym XF86KbdBrightnessUp     exec ${pkgs.light}/bin/light -s sysfs/leds/kbd_backlight -A 1 && ${pkgs.light}/bin/light -s sysfs/leds/kbd_backlight -G | cut -d'.' -f1 > $SWAYSOCK.wob
    bindsym XF86KbdBrightnessDown   exec ${pkgs.light}/bin/light -s sysfs/leds/kbd_backlight -U 1 && ${pkgs.light}/bin/light -s sysfs/leds/kbd_backlight -G | cut -d'.' -f1 > $SWAYSOCK.wob
    bindsym Shift+XF86MonBrightnessUp     exec ${pkgs.light}/bin/light -s sysfs/leds/kbd_backlight -A 1 && ${pkgs.light}/bin/light -s sysfs/leds/kbd_backlight -G | cut -d'.' -f1 > $SWAYSOCK.wob
    bindsym Shift+XF86MonBrightnessDown   exec ${pkgs.light}/bin/light -s sysfs/leds/kbd_backlight -U 1 && ${pkgs.light}/bin/light -s sysfs/leds/kbd_backlight -G | cut -d'.' -f1 > $SWAYSOCK.wob

    bindsym ${modifier}+F3          exec echo $(expr $(cat /sys/devices/platform/asus-nb-wmi/hwmon/hwmon3/pwm1) - 3) > /sys/devices/platform/asus-nb-wmi/hwmon/hwmon3/pwm1
    bindsym ${modifier}+F4          exec echo $(expr $(cat /sys/devices/platform/asus-nb-wmi/hwmon/hwmon3/pwm1) + 3) > /sys/devices/platform/asus-nb-wmi/hwmon/hwmon3/pwm1
    bindsym ${modifier}+F2          exec echo $([[ $(cat /sys/devices/platform/asus-nb-wmi/hwmon/hwmon3/pwm1_enable) = 2 ]] && echo 1 || echo 2) > /sys/devices/platform/asus-nb-wmi/hwmon/hwmon3/pwm1_enable

    bindsym XF86AudioRaiseVolume    exec ${pkgs.pamixer}/bin/pamixer -ui 2 && ${pkgs.pamixer}/bin/pamixer --get-volume > $SWAYSOCK.wob
    bindsym XF86AudioLowerVolume    exec ${pkgs.pamixer}/bin/pamixer -ud 2 && ${pkgs.pamixer}/bin/pamixer --get-volume > $SWAYSOCK.wob
    bindsym XF86AudioMute           exec ${pkgs.pamixer}/bin/pamixer --toggle-mute && ( ${pkgs.pamixer}/bin/pamixer --get-mute && echo 0 > $SWAYSOCK.wob ) || ${pkgs.pamixer}/bin/pamixer --get-volume > $SWAYSOCK.wob
    bindsym XF86AudioPlay           exec ${pkgs.playerctl}/bin/playerctl play
    bindsym XF86AudioPause          exec ${pkgs.playerctl}/bin/playerctl pause

    bindsym XF86MonBrightnessUp     exec ${pkgs.light}/bin/light -A 1 && ${pkgs.light}/bin/light -G | cut -d'.' -f1 > $SWAYSOCK.wob
    bindsym XF86MonBrightnessDown   exec ${pkgs.light}/bin/light -U 1 && ${pkgs.light}/bin/light -G | cut -d'.' -f1 > $SWAYSOCK.wob

    bindsym ${modifier}+F5  opacity minus 0.05
    bindsym ${modifier}+F6  opacity plus  0.05

    bindsym XF86PowerOff            exec ${lock}/bin/lock.sh


    bindsym ${modifier}+F11         fullscreen

    bindsym --to-code Control+Space       exec ${pkgs.mako}/bin/makoctl dismiss
    bindsym --to-code Control+Shift+Space exec ${pkgs.mako}/bin/makoctl dismiss -a
  '';
}

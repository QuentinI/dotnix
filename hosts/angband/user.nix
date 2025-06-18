{
  vars,
  flake-inputs,
  mkImports,
  nur,
  pkgs-stable,
  system,
  ...
}:

{
  home-manager.extraSpecialArgs = { inherit flake-inputs system; };
  home-manager.users."${vars.username}" =
    {
      pkgs,
      ...
    }:
    {
      home.stateVersion = "23.11";

      home.packages = [
        pkgs.alt-tab-macos
        pkgs.obsidian
        pkgs.discord
        pkgs.spotify
        pkgs.jdk21
        pkgs.qbittorrent
        pkgs.mpv
        pkgs.mr
        pkgs.nushell
	      pkgs.docker
	      pkgs.docker-compose
	      pkgs.colima
	      pkgs.lazygit
	      pkgs.mergiraf
			  pkgs.drawio
        (pkgs.hiPrio pkgs.rustup)
      ];

      _module.args = {
        inherit nur pkgs-stable;
      };

      imports =
        [
          nur.repos.rycee.hmModules.theme-base16
        ]
        ++ mkImports "home" [
          ../../modules/profiles/base.nix

          ../../modules/programs/git
          ../../modules/programs/zsh
          ../../modules/programs/helix
          ../../modules/programs/tdesktop
          ../../modules/programs/firefox
          ../../modules/programs/wezterm
          ../../modules/services/syncthing.nix
        ];

      xdg.configFile."hm/theme" = {
        text = vars.theme;
      };

      home.file.".hammerspoon/init.lua" = {
        text = ''
            local yabai = {}

            -- Helper function to execute yabai commands
            function yabai.exec(command)
                local args = {"-m"}
                local commandArgs = hs.fnutils.split(command, " ")
                for _, arg in ipairs(commandArgs) do
                    table.insert(args, arg)
                end
                hs.task.new("${pkgs.yabai}/bin/yabai", nil, args):start()
            end

            -- Helper function to get yabai output
            function yabai.query(command)
                local args = {"-m"}
                local commandArgs = hs.fnutils.split(command, " ")
                for _, arg in ipairs(commandArgs) do
                    table.insert(args, arg)
                end

                local output = "";
                local task = hs.task.new("${pkgs.yabai}/bin/yabai", function(_, stdOut, _)
                  output = stdOut
                end, args)
                task:start():waitUntilExit()
                return output
            end

            -- Modifier key combinations (like i3's $mod)
            local mod = {"cmd"}
            local modShift = {"cmd", "shift"}
            local modCtrl = {"cmd", "ctrl"}
            local modShiftCtrl = {"cmd", "shift", "ctrl"}

            hs.hotkey.bind(mod, "h", function()
                yabai.exec("window --focus west")
            end)

            hs.hotkey.bind(mod, "j", function()
                yabai.exec("window --focus south")
            end)

            hs.hotkey.bind(mod, "k", function()
                yabai.exec("window --focus north")
            end)

            hs.hotkey.bind(mod, "l", function()
                yabai.exec("window --focus east")
            end)

            hs.hotkey.bind(mod, "return", function()
                hs.application.launchOrFocus("WezTerm")
            end)

            hs.hotkey.bind(modShift, "space", function()
                yabai.exec("window --toggle float")
            end)

            hs.hotkey.bind(modShift, "h", function()
                yabai.exec("window --warp west")
            end)

            hs.hotkey.bind(modShift, "j", function()
                yabai.exec("window --warp south")
            end)

            hs.hotkey.bind(modShift, "k", function()
                yabai.exec("window --warp north")
            end)

            hs.hotkey.bind(modShift, "l", function()
                yabai.exec("window --warp east")
            end)

            hs.hotkey.bind(modShift, "right", function()
                yabai.exec("yabai -m space --display east")
            end)

            hs.hotkey.bind(modShift, "left", function()
                yabai.exec("yabai -m space --display west")
            end)

            hs.hotkey.bind(mod, "§", function()
                local output = yabai.query("query --spaces --space")
                local current_layout = string.match(output, '"type":"([^"]*)"')

                if current_layout == "bsp" then
                    yabai.exec("space --layout stack")
                elseif current_layout == "stack" then
                    yabai.exec("space --layout bsp")
                else
                    -- Default to bsp if currently in float or other layout
                    yabai.exec("space --layout bsp")
                end
            end)

            hs.hotkey.bind(modShift, "x", function()
              yabai.exec("query --windows --space | jq '.[].id' | xargs -I{} yabai -m window {} --toggle float")
              hs.timer.doAfter(1, function()
                  yabai.exec("query --windows --space | jq '.[].id' | xargs -I{} yabai -m window {} --toggle float")
                  hs.timer.doAfter(0.5, function()
                      yabai.exec("window --focus first")
                  end)
              end)
              hs.alert.show("Stack reset")
            end)

            for num = 1, 9 do
          	  local name = tostring(num)
              hs.hotkey.bind(mod, name, function()
          	    local command = "${pkgs.yabai}/bin/yabai -m space --focus " .. name
          	    hs.execute(command)
              end)
              hs.hotkey.bind(modShift, name, function()
                yabai.exec("window --space " .. name)
              end)
            end
        '';
      };

      theme.base16.colors = builtins.mapAttrs (_: v: {
        hex.r = builtins.substring 0 2 v;
        hex.g = builtins.substring 2 2 v;
        hex.b = builtins.substring 4 2 v;
      }) (import ../../themes/remix.nix);
    };
}

{
  config,
  vars,
  pkgs,
  inputs,
  secrets,
  naersk,
  napalm,
  mkImports,
  nur,
  pkgs-stable,
  ...
}:

{
  home-manager.users."${vars.username}" =
    {
      system,
      config,
      pkgs,
      inputs,
      staging,
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
          ../../modules/programs/tdesktop
          ../../modules/programs/firefox
          ../../modules/services/syncthing.nix
        ];

      xdg.configFile."hm/theme" = {
        text = vars.theme;
      };

      home.file.".hammerspoon/init.lua" = {
        text = ''
                  for num = 1, 9 do
          	  local name = tostring(num)
                    hs.hotkey.bind("cmd", name, function()
          	    local command = "${pkgs.yabai}/bin/yabai -m space --focus " .. name
          	     hs.execute(command)
                    end)
                    hs.hotkey.bind({"cmd", "shift"}, name, function()
                      local win = hs.window.focusedWindow()
                      local spaces = hs.spaces.spacesForScreen()
                      hs.spaces.moveWindowToSpace(win, spaces[num], true)
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

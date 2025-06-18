{
  home = { config, flake-inputs, system, ... }:
  {
    programs.wezterm.enable = true;
    programs.wezterm.enableZshIntegration = true;
    programs.wezterm.extraConfig = ''
      local wezterm = require 'wezterm'
      local act = wezterm.action

      local config = wezterm.config_builder()

      local keys = {}
      for i = 1, 9 do
        table.insert(keys, {
          mods = 'ALT',
          key = tostring(i),
          action = act.ActivateTab(i - 1),
        })
      end
      config.keys = keys

      config.font = wezterm.font('Fira Code', { weight = 'Medium' })
      config.font_size = 16

      config.window_frame = {
        font_size = 14.0,
        density = 'Comfortable',
      }
      config.window_decorations = "RESIZE"
      config.window_padding = {
        left = 0,   -- Minimal padding for tiling
        right = 0,
        top = 0,
        bottom = 0,
      }
      config.hide_tab_bar_if_only_one_tab = true
      config.native_macos_fullscreen_mode = false
      config.adjust_window_size_when_changing_font_size = false

      config.window_close_confirmation = 'NeverPrompt'

      wezterm.on('window-config-reloaded', function(window, pane)
        local appearance = window:get_appearance()
        local scheme = appearance:find("Dark") and "Nord (Gogh)" or "ayu_light"

        local overrides = window:get_config_overrides() or {}
        if overrides.color_scheme ~= scheme then
          overrides.color_scheme = scheme
          window:set_config_overrides(overrides)
        end
      end)

      config.scrollback_lines = 81920000
      config.enable_scroll_bar = true
      config.audible_bell = "Disabled"
      config.check_for_updates = false

      -- Finally, return the configuration to wezterm:
      return config
    '';
  };
}

{
  pkgs,
  flake-inputs,
  inputs,
  ...
}:
let
  scripts = "mpv/scripts";
  modules = "mpv/script-modules";

in
{
  home.packages = with pkgs; [ mpv ]; # python3Packages.subliminal ];

  xdg.configFile.mpv_conf = {
    source = ./mpv.conf;
    target = "mpv/mpv.conf";
  };

  xdg.configFile.mpv_subit = {
    source = "${flake-inputs.mpv-scripts}/subit.lua";
    target = "${scripts}/subit.lua";
  };

  xdg.configFile.mpv_undo_redo = {
    source = "${flake-inputs.mpv-scripts}/UndoRedo.lua";
    target = "${scripts}/UndoRedo.lua";
  };

  xdg.configFile.mpv_chapters = {
    source = "${flake-inputs.mpv-chapters}/mpv_chapters.js";
    target = "${scripts}/mpv_chapters.js";
  };

  xdg.configFile.mpv_search_page = {
    source = "${flake-inputs.mpv-search-page}/search-page.lua";
    target = "${scripts}/search-page.lua";
  };

  xdg.configFile.mpv_search_page_conf = {
    source = "${flake-inputs.mpv-search-page}/search_page.conf";
    target = "${scripts}/search_page.conf";
  };

  xdg.configFile.mpv_user_input = {
    source = "${flake-inputs.mpv-user-input}/user-input.lua";
    target = "${modules}/user-input.lua";
  };

  xdg.configFile.mpv_user_input_module = {
    source = "${flake-inputs.mpv-user-input}/user-input-module.lua";
    target = "${modules}/user-input-module.lua";
  };

  xdg.configFile.mpv_scroll_list = {
    source = "${flake-inputs.mpv-scroll-list}/scroll-list.lua";
    target = "${modules}/scroll-list.lua";
  };

}

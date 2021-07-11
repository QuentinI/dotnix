{ config, pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    mpv
    python3Packages.subliminal
  ];

  xdg.configFile.mpv_subit = {
    source = "${inputs.mpv-scripts}/scripts/subit.lua";
    target = "mpv/scripts/subit.lua";
  };

  xdg.configFile.mpv_undo_redo = {
    source = "${inputs.mpv-scripts}/scripts/UndoRedo.lua";
    target = "mpv/scripts/UndoRedo.lua";
  };

  xdg.configFile.mpv_chapters = {
    source = "${inputs.mpv-chapters}/mpv_chapters.js";
    target = "mpv/scripts/mpv_chapters.js";
  };

}

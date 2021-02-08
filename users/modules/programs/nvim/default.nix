{ config, pkgs, ... }:

let
  theme = import ../../themes { inherit pkgs; };
  nvim_plug = "${(import ../../../nix/sources.nix).vim-plug}/plug.vim";
  init = builtins.replaceStrings [
    "{%colorscheme_plug%}"
    "{%colorscheme_activate%}"
  ] [ "'${theme.vim.plugname}'" theme.vim.activate ]
    (builtins.readFile ./init.vim);
in {

  home.packages = [ pkgs.neovim ];

  xdg.configFile.nvim_init = {
    text = init;
    target = "nvim/init.vim";
  };

  xdg.configFile.nvim_coc = {
    source = ./coc-settings.json;
    target = "nvim/coc-settings.json";
  };

  home.file.nvim_plug = {
    text = builtins.readFile nvim_plug;
    target = ".local/share/nvim/site/autoload/plug.vim";
  };

  # programs.neovim.enable = true;
}

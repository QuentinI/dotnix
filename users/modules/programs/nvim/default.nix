{ config, pkgs, inputs, ... }:

let
  nvim_plug = "${inputs.vim-plug}/plug.vim";
  init = builtins.readFile ./init.vim;
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
}

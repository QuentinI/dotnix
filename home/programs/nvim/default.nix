{ config, pkgs, ... }:

let
  theme = import ../../themes { inherit pkgs; };
  init = builtins.replaceStrings ["{%colorscheme_plug%}" "{%colorscheme_activate%}"] [ "'${theme.vim.plugname}'" theme.vim.activate ] (builtins.readFile ./init.vim);
in
{
  
  home.packages = [
    pkgs.neovim
  ];

  xdg.configFile.nvim_init = {
    text = init;
    target = "nvim/init.vim";
  };

  xdg.configFile.nvim_coc = {
    source = ./coc-settings.json;
    target = "nvim/coc-settings.json";
  };

  home.file.nvim_plug = {
    text = builtins.readFile (
      pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim";
        sha256 = "1wqbcqriba20khlx1khj1ndxbffcppd1ffw6an8n644zg1gv5r29";
      }
    );
    target = ".local/share/nvim/site/autoload/plug.vim";
  };

  programs.neovim.enable = true;
}

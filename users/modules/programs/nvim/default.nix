{ config, pkgs, inputs, ... }:

let
  nvim_plug = "${inputs.vim-plug}/plug.vim";
  init = (builtins.readFile ./init.vim) + (with config.theme.base16.colors; ''
    lua << EOF
      require('base16-colorscheme').setup({
          base00 = '#${base00.hex.rgb}', base01 = '#${base01.hex.rgb}',
          base02 = '#${base02.hex.rgb}', base03 = '#${base03.hex.rgb}',
          base04 = '#${base04.hex.rgb}', base05 = '#${base05.hex.rgb}',
          base06 = '#${base06.hex.rgb}', base07 = '#${base07.hex.rgb}',
          base08 = '#${base08.hex.rgb}', base09 = '#${base09.hex.rgb}',
          base0A = '#${base0A.hex.rgb}', base0B = '#${base0B.hex.rgb}',
          base0C = '#${base0C.hex.rgb}', base0D = '#${base0D.hex.rgb}',
          base0E = '#${base0E.hex.rgb}', base0F = '#${base0F.hex.rgb}',
      })
    EOF
  '');
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

{
  config,
  pkgs,
  inputs,
  ...
}:

{
  programs.bat = {
    enable = true;
    config = {
      paging = "never";
      color = "always";
    };
  };
}

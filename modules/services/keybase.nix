{
  home =
    { pkgs, ... }:

    {
      home.packages = [ pkgs.keybase-gui ];
      services.keybase.enable = true;
      services.kbfs.enable = true;
    };
}

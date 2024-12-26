{
  home =
    { ... }:
    {
      services.gpg-agent = {
        enable = true;
        #     extraConfig = ''
        #       pinentry-program ${pkgs.pinentry_gtk2}/bin/pinentry-gtk-2
        #     '';
      };
      home.packages = [
        # pkgs.pinentry-gtk2
      ];
    };

}

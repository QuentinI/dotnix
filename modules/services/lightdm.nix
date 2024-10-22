{
  config,
  pkgs,
  vars,
  ...
}:

{
  services.xserver = {
    enable = true;
    libinput.enable = true;
    displayManager = {
      defaultSession = "sway";
      lightdm = {
        enable = true;
      };
    };
    config = "";
    layout = "us,ru";
  };
}

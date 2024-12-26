{ ... }:

{
  services.xserver = {
    enable = true;
    libinput.enable = true;
    displayManager = {
      defaultSession = "sway";
      sddm = {
        enable = true;
        settings.Users.HideUsers = "jupyter";
      };
    };
    config = "";
    layout = "us,ru";
  };
}

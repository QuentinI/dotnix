{
  nixos = {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      media-session = {
        config = {
          bluez-monitor = {
            rules = [{
              # Matches all cards
              matches = [{ "device.name" = "~bluez_card.*"; }];
              actions = {
                "update-props" = {
                  "bluez5.msbc-support" = true;
                  "bluez5.sbc-xq-support" = true;
                };
              };
            }];
          };
        };
      };
    };
  };
}

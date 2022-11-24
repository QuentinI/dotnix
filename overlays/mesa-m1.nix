# Overlay of mesa with Asahi GPU driver support
# If by any chance you stumble upon this:
# PLEASE think twice before using this, there's a reason
# Lina's driver isn't released yet. If you will still end
# up using it - PLEASE don't go and complain to Asahi team
# about your computer exploding or something, I don't want
# to cause them problems. Don't complain to me either,
# although you may ask questions.
_: super:
rec {
  mesa_asahi = super.mesa.overrideAttrs (old: rec {
    version = "22.3.0-rc4-asahi";
    rev = "6c24545f0dd3ba455863da0d98db9b765368ef56";
    src = super.fetchurl {
      url = "https://gitlab.freedesktop.org/alyssa/mesa/-/archive/${rev}/${rev}.tar.gz";
      hash = "sha256-UHR49Q0kMV3USNXew74f49gZ3OqfQCHaO2xv3TGKR5g=";
    };
    mesonFlags = builtins.filter
      (flag: builtins.match ".*xvmc.*" flag == null) # No idea why it's problematic
      old.mesonFlags;
  });
  mesa = mesa_asahi.override {
    galliumDrivers = [ "asahi" "swrast" ];
    vulkanDrivers = [ "swrast" ];
    enableGalliumNine = false;
  };
}

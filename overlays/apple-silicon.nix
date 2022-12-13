_: super:
rec {
  # Overlay of mesa with Asahi GPU driver support
  # If by any chance you stumble upon this:
  # PLEASE think twice before using this, there's a reason
  # Lina's driver isn't released yet. If you will still end
  # up using it - PLEASE don't go and complain to Asahi team
  # about your computer exploding or something, I don't want
  # to cause them problems. Don't complain to me either,
  # although you may ask questions.
  mesa_asahi = super.mesa.overrideAttrs (old: rec {
    version = "22.3.0-rc4-asahi";
    rev = "3fc6e787ce9da1b5e323974ca134647d69dd2573";
    src = super.fetchurl {
      url = "https://gitlab.freedesktop.org/asahi/mesa/-/archive/${rev}/${rev}.tar.gz";
      hash = "sha512-g/ZiqkAqaPbyNrrRi2yj8aTxmpogzmo4VgKzDgrzcXqzDgrpOH3ObO4UFTVDh3ZAOBXS61Pbj+GOw2AnAYEkWQ==";
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

  # https://github.com/sharkdp/fd/issues/1085
  fd = super.fd.overrideAttrs (_: {
    JEMALLOC_SYS_WITH_LG_PAGE = 16;
  });
}

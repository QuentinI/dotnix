self:
super:

{
  picom = super.stdenv.mkDerivation rec {
    pname = "picom";
    version = "7.4";

    src = super.fetchFromGitHub {
      owner  = "yshui";
      repo   = "picom";
      rev    = "v${version}";
      sha256 = "11mrfiivwa1lba1ipck0l6q86ngwv1p0rs2dln05mk1904qbnj9h";
      fetchSubmodules = true;
    };

    nativeBuildInputs = with self; [
      meson ninja
      pkgconfig
      uthash
      asciidoc
      docbook_xml_dtd_45
      docbook_xsl
      makeWrapper
    ];

    buildInputs = with self; [
      dbus xorg.libX11 xorg.libXext
      xorg.xorgproto
      xorg.libXinerama libdrm pcre libxml2 libxslt libconfig libGL
      xorg.libxcb xorg.xcbutilrenderutil xorg.xcbutilimage
      pixman libev
      libxdg_basedir
    ];

    NIX_CFLAGS_COMPILE = [ "-fno-strict-aliasing" ];

    mesonFlags = [
      "-Dbuild_docs=true"
    ];

    installFlags = [ "PREFIX=$(out)" ];

    postInstall = ''
      wrapProgram $out/bin/compton-trans \
        --prefix PATH : ${self.lib.makeBinPath [ self.xorg.xwininfo ]}
    '';
  };
}

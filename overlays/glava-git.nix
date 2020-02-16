self:
super:

let
  inherit (super.stdenv.lib) optional makeLibraryPath;

  wrapperScript = super.writeScript "glava" ''
    #!${super.runtimeShell}
    case "$1" in
      --copy-config)
        # The binary would symlink it, which won't work in Nix because the
        # garbage collector will eventually remove the original files after
        # updates
        echo "Nix wrapper: Copying glava config to ~/.config/glava"
        cp -r --no-preserve=all @out@/etc/xdg/glava ~/.config/glava
        ;;
      *)
        exec @out@/bin/.glava-unwrapped "$@"
    esac
  '';
in

{
  glava-git = super.stdenv.mkDerivation rec {
    name = "glava-git-${version}";
    version = "1.6.3";

    src = super.fetchFromGitHub {
      owner = "wacossusca34";
      repo = "glava";
      rev = "v1.6.3";
      sha256 = "0kqkjxmpqkmgby05lsf6c6iwm45n33jk5qy6gi3zvjx4q4yzal1i";
    };

    buildInputs = with self; [
      xorg.libX11
      xorg.libXext
      xorg.libXrandr
      xorg.libXrender
      libpulseaudio
      xorg.libXcomposite
      glfw
    ];

    nativeBuildInputs = [
      self.python3
    ];

    preConfigure = ''
      export CFLAGS="-march=native"
    '';

    patchPhase = ''
      sed -e "s@DSHADER_INSTALL_PATH@DSHADER_INSTALL_PATH_IGNORE@" -i Makefile
      sed -e "s@/etc/xdg/glava@$out/etc/xdg/glava@" -i glava.c
    '';

    installFlags = [
      "DESTDIR=$(out)"
    ];

    fixupPhase = ''
      mkdir -p $out/bin
      mv $out/usr/bin/glava $out/bin/.glava-unwrapped
      rm -rf $out/usr

      patchelf \
        --set-rpath "$(patchelf --print-rpath $out/bin/.glava-unwrapped):${makeLibraryPath [ super.libGL ]}" \
        $out/bin/.glava-unwrapped

      substitute ${wrapperScript} $out/bin/glava --subst-var out
      chmod +x $out/bin/glava
    '';

    meta = with super.stdenv.lib; {
      description = ''
        OpenGL audio spectrum visualizer
      '';
      homepage = https://github.com/wacossusca34/glava;
      platforms = platforms.linux;
      license = licenses.gpl3;
    };  
  };
}

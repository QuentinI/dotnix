{ stdenv
, lib
, fetchFromGitHub
, pkgsCross
, python3
, dtc
, imagemagick
, isRelease ? false
, withTools ? true
, withChainloading ? false
, rust-bin ? null
, customLogo ? null
}:

assert withChainloading -> rust-bin != null;

let
  pyenv = python3.withPackages (p: with p; [
    construct
    pyserial
  ]);

  rustenv = rust-bin.selectLatestNightlyWith (toolchain: toolchain.minimal.override {
    targets = [ "aarch64-unknown-none-softfloat" ];
  });
in stdenv.mkDerivation rec {
  pname = "m1n1";
  version = "1.1.7";

  src = fetchFromGitHub {
    # tracking: https://github.com/AsahiLinux/PKGBUILDs/blob/main/m1n1/PKGBUILD
    owner = "AsahiLinux";
    repo = "m1n1";
    rev = "v${version}";
    hash = "sha256-dtj3SQsWdpjBkPOU7frD6BEV1AaSLz5jdE1aJeyf0NU=";
    fetchSubmodules = true;
  };

  makeFlags = [ "ARCH=aarch64-unknown-linux-gnu-" ]
    ++ lib.optional isRelease "RELEASE=1"
    ++ lib.optional withChainloading "CHAINLOADING=1";

  nativeBuildInputs = [
    dtc
    pkgsCross.aarch64-multiplatform.buildPackages.gcc
  ] ++ lib.optional withChainloading rustenv
    ++ lib.optional (customLogo != null) imagemagick;

  postPatch = ''
    substituteInPlace proxyclient/m1n1/asm.py \
      --replace 'aarch64-linux-gnu-' 'aarch64-unknown-linux-gnu-' \
      --replace 'TOOLCHAIN = ""' 'TOOLCHAIN = "'$out'/toolchain-bin/"'
  '';

  preConfigure = lib.optionalString (customLogo != null) ''
    pushd data &>/dev/null
    ln -fs ${customLogo} bootlogo_256.png
    if [[ "$(magick identify bootlogo_256.png)" != 'bootlogo_256.png PNG 256x256'* ]]; then
      echo "Custom logo is not a 256x256 PNG"
      exit 1
    fi

    rm bootlogo_128.png
    convert bootlogo_256.png -resize 128x128 bootlogo_128.png
    ./makelogo.sh
    popd &>/dev/null
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/build
    cp build/m1n1.macho $out/build
    cp build/m1n1.bin $out/build
  '' + (lib.optionalString withTools ''
    mkdir -p $out/{bin,script,toolchain-bin}
    cp -r proxyclient $out/script
    cp -r tools $out/script

    for toolpath in $out/script/proxyclient/tools/*.py; do
      tool=$(basename $toolpath .py)
      script=$out/bin/m1n1-$tool
      cat > $script <<EOF
#!/bin/sh
${pyenv}/bin/python $toolpath "\$@"
EOF
      chmod +x $script
    done

    GCC=${pkgsCross.aarch64-multiplatform.buildPackages.gcc}
    BINUTILS=${pkgsCross.aarch64-multiplatform.buildPackages.binutils-unwrapped}

    ln -s $GCC/bin/*-gcc $out/toolchain-bin/
    ln -s $GCC/bin/*-ld $out/toolchain-bin/
    ln -s $BINUTILS/bin/*-objcopy $out/toolchain-bin/
    ln -s $BINUTILS/bin/*-objdump $out/toolchain-bin/
    ln -s $GCC/bin/*-nm $out/toolchain-bin/
  '') + ''
    runHook postInstall
  '';
}
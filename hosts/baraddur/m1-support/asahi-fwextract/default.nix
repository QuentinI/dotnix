{ lib
, python3
, fetchFromGitHub
, gzip
, gnutar
, lzfse
}:

python3.pkgs.buildPythonApplication rec {
  pname = "asahi-fwextract";
  version = "0.5.2";

  # tracking version: https://github.com/AsahiLinux/PKGBUILDs/blob/main/asahi-fwextract/PKGBUILD
  src = fetchFromGitHub {
    owner = "AsahiLinux";
    repo = "asahi-installer";
    rev = "v${version}";
    hash = "sha256-5ux5DwuyP0eXiD14bKJCY5flbjGfNTXk8FswW/bqfGY=";
  };

  postPatch = ''
    substituteInPlace asahi_firmware/img4.py \
      --replace 'liblzfse.so' '${lzfse}/lib/liblzfse.so'
    substituteInPlace asahi_firmware/update.py \
      --replace '"tar"' '"${gnutar}/bin/tar"' \
      --replace '"xf"' '"-x", "-I", "${gzip}/bin/gzip", "-f"'
  '';

  nativeBuildInputs = [ python3.pkgs.setuptools ];

  doCheck = false;
}

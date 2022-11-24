{ pkgs, _4KBuild ? false }:
let
  localPkgs =
    # we do this so the config can be read on any system and not affect
    # the output hash
    if builtins ? currentSystem then import (pkgs.path) { system = builtins.currentSystem; }
    else pkgs;

  readConfig = configfile: import (localPkgs.runCommand "config.nix" { } ''
    echo "{" > "$out"
    while IFS='=' read key val; do
      [ "x''${key#CONFIG_}" != "x$key" ] || continue
      no_firstquote="''${val#\"}";
      echo '  "'"$key"'" = "'"''${no_firstquote%\"}"'";' >> "$out"
    done < "${configfile}"
    echo "}" >> $out
  '').outPath;

  linux_asahi_pkg =
    { stdenv
    , lib
    , fetchFromGitHub
    , fetchpatch
    , linuxKernel
    , rustPlatform
    , rustfmt
    , rust-bindgen
    , ...
    } @ args:
    (linuxKernel.manualConfig
      rec {
        inherit stdenv lib;

        version = "6.1.0-rc5-asahi";
        modDirVersion = version;

        src = fetchFromGitHub {
          owner = "AsahiLinux";
          repo = "linux";
          rev = "1087f668f666a257db411fd6655de488c8578543";
          hash = "sha256-o/Ey8YAgo4TAamUBr+oxTzSVFBhFpeTKVzAb+4iqZ5c=";
        };

        kernelPatches = [
          {
            name = "ignore-notch";
            patch = ./ignore-notch.patch;
          }
        ] ++ lib.optionals _4KBuild [
          # thanks to Sven Peter
          # https://lore.kernel.org/linux-iommu/20211019163737.46269-1-sven@svenpeter.dev/
          {
            name = "sven-iommu-4k";
            patch = ./sven-iommu-4k.patch;
          }
        ] ++ lib.optionals (!_4KBuild) [
          # patch the kernel to set the default size to 16k instead of modifying
          # the config so we don't need to convert our config to the nixos
          # infrastructure or patch it and thus introduce a dependency on the host
          # system architecture
          {
            name = "default-pagesize-16k";
            patch = ./default-pagesize-16k.patch;
          }
        ];

        configfile = ./config;
        config = readConfig configfile;

        extraMeta.branch = "6.1";
      } // (args.argsOverride or { })).overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ rust-bindgen rustfmt rustPlatform.rust.rustc ];
      RUST_LIB_SRC = rustPlatform.rustLibSrc;
    });

  linux_asahi = (pkgs.callPackage linux_asahi_pkg { });
in
pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux_asahi)

{ stdenv, fetchFromGitHub, ... }:

{
  aw-watcher-window-wayland = stdenv.mkDerivation {
    name = "aw-watcher-window-wayland";

    src = fetchFromGitHub {
      owner = "ActivityWatch";
      repo = "aw-watcher-window-wayland";
      rev = "1cd055517bbeda98b179d3cf855f5312e564d5bd";
      sha256 = "B/YvtP3l3fHIF70UPiuuW7KL0TLca6EHkuOuETEGT0I=";
    };

    # Patch cargo files for naersk compatibility
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup

      cp -r $src $out/
      chmod -R +w $out/

      sed -E 's@aw_client_rust.*$@aw_client_rust = \{ git = "https://github.com/ActivityWatch/aw-client-rust.git", rev = "caea2b441877eb8000786d0464c09034380f999f" \}@g' -i $out/Cargo.toml
      sed -E 's@source = "git\+https://github.com/ActivityWatch/aw-client-rust.git#caea2b441877eb8000786d0464c09034380f999f"@source = "git+https://github.com/ActivityWatch/aw-client-rust.git?rev=caea2b441877eb8000786d0464c09034380f999f#caea2b441877eb8000786d0464c09034380f999f"@g' -i $out/Cargo.lock
    '';
  };

  activitywatch = stdenv.mkDerivation {
    name = "activitywatch-source";
    src = fetchFromGitHub {
      owner = "ActivityWatch";
      repo = "activitywatch";
      rev = "75e8e2c0b7714afa3d98b70a2178bbc419d06443";
      sha256 = "ZliKlxlJsapmv7sQMkJI7GsS27esuUUjauVASjfv0J8=";
      fetchSubmodules = true;
    };

    # Patch cargo files for naersk compatibility
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup

      cp -r $src $out/
      chmod -R +w $out/

      sed -E 's@rocket_cors = \{ git = "https://github.com/lawliet89/rocket_cors", rev = "a062933" \}@rocket_cors = \{ git = "https://github.com/lawliet89/rocket_cors", rev = "a062933c1b109949c618b0dba296ac33e4b1a105" \}@g' -i $out/aw-server-rust/aw-server/Cargo.toml
      sed -E 's@source = "git\+https://github.com/lawliet89/rocket_cors\?rev=a062933#a062933c1b109949c618b0dba296ac33e4b1a105"@source = "git\+https://github.com/lawliet89/rocket_cors\?rev=a062933c1b109949c618b0dba296ac33e4b1a105#a062933c1b109949c618b0dba296ac33e4b1a105"@g' -i $out/aw-server-rust/Cargo.lock
    '';
  };
}

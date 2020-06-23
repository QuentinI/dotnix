# FIXME: broken on unstable
let
  sources = import ../../../nix/sources.nix;
  pkgs-release = import "${sources.nixpkgs-release}" {
    config = {
      allowBroken = true;
    };
  };
in
{
  programs.beets = {
    package = pkgs-release.beets;
    enable = true;
    settings = {
      directory = "~/Music/";
      library = "~/Music/.beets_library.db";
      plugins =
        "acousticbrainz badfiles convert chroma fetchart ftintitle lastgenre lyrics missing replaygain scrub web";
      original_date = true;

      import = {
        move = true;
        bell = true;
      };

    };
  };
}

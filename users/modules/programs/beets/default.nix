{ pkgs, ... }:

{
  programs.beets = {
    package = pkgs.beets;
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

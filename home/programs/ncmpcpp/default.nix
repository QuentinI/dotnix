{ pkgs, ... }:

{
  home.file.ncmpcpp = {
    text = ''
      mpd_host = "localhost"
      mpd_port = "6600"
      mpd_music_dir = "~/Music"
      mpd_connection_timeout = "5"

      # Progress
      progressbar_look              = "── "

      # Playlist view
      song_columns_list_format = (20)[white]{a} (50)[cyan]{t|f:Title} (20)[cyan]{b} (7f)[white]{l}
      now_playing_prefix = $u
      now_playing_suffix = $/u

      main_window_color = white
   '';
   target = ".ncmpcpp/config";
  };

  home.file.ncmpcpp_bindings = {
    text = ''
      def_key "+"
              show_clock
      def_key "="
          volume_up
      
      def_key "j"
          scroll_down
      def_key "k"
          scroll_up
      def_key "h"
          previous_column
      def_key "l"
          next_column
      
      def_key "ctrl-u"
          page_up
      
      def_key "ctrl-d"
          page_down
      
      
      def_key "."
          show_lyrics
      
      def_key "n"
          next_found_item
      def_key "N"
          previous_found_item
      
      def_key "J"
          move_sort_order_down
      def_key "K"
          move_sort_order_up
      
      def_key "d"
        delete_playlist_items
      
      def_key "d"
        delete_browser_items
    '';
    target = ".ncmpcpp/bindings";
  };

  home.packages = [
    pkgs.ncmpcpp
    # TODO:
    # pkgs.glava-git
  ];
}

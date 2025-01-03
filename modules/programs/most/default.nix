{ pkgs, ... }:

{
  home.packages = [ pkgs.most ];
  home.file.".mostrc".text = ''
    % Keybindings
    unsetkey "^K"
    setkey up "^K"
    unsetkey ":"
    setkey next_file ":n"
    setkey find_file ":e"
    setkey next_file ":p"
    setkey toggle_options ":o"
    setkey toggle_case ":c"
    setkey delete_file ":d"
    setkey exit ":q"
    setkey down "e"
    setkey down "E"
    setkey down "j"
    setkey down "^N"
    setkey up "y"
    setkey up "^Y"
    setkey up "k"
    setkey up "^P"
    setkey page_down "f"
    setkey page_down "^F"
    setkey page_up "b"
    setkey page_up "^B"
    setkey other_window "z"
    setkey other_window "w"
    setkey search_backward "?"
    setkey bob "p"
    setkey goto_mark "'"
    setkey find_file "E"
    setkey edit "v"
  '';
}

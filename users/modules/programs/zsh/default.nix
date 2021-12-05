{ pkgs, ... }:

# Kudos to https://github.com/ranger/ranger/blob/master/ranger/data/scope.sh
let
  preview-file = pkgs.writeShellScriptBin "preview-file.sh" ''
    FILE_PATH="$1"
    FILE_EXTENSION="''${FILE_PATH##*.}"
    FILE_EXTENSION_LOWER="$(printf "%s" "''${FILE_EXTENSION}" | tr '[:upper:]' '[:lower:]')"

    if [[ -d "$FILE_PATH" ]]; then
      exa -lh --no-permissions --no-user --group-directories-first --git --color=always "$FILE_PATH"
      exit 0
    fi

    case "''${FILE_EXTENSION_LOWER}" in
      ## Image
      jpeg|jpg|png|gif|tiff|ppm|pgm|pbm|bmp|pcx|avi|mp4|mkv|mov|webm|mpeg|flv|vob|ogv)
        timg -E --frames=1 --loops=1 -g $(( $COLUMNS / 2 - 4 ))x$(( $FZF_PREVIEW_LINES * 2 )) "''${FILE_PATH}";
        ;;
      ## Archive
      a|ace|alz|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzh|lzma|lzo|\
      rpm|rz|t7z|tar|tbz|tbz2|tgz|tlz|txz|tZ|tzo|war|xpi|xz|Z|zip)
        atool --list -- "''${FILE_PATH}"
        bsdtar --list --file "''${FILE_PATH}"
        ;;
      rar)
        ## Avoid password prompt by providing empty password
        unrar lt -p- -- "''${FILE_PATH}"
        ;;
      7z)
        ## Avoid password prompt by providing empty password
        7z l -p -- "''${FILE_PATH}"
        ;;
      ## PDF
      pdf)
        ## Preview as text conversion
        pdftotext -l 10 -nopgbrk -q -- "''${FILE_PATH}" -
        mutool draw -F txt -i -- "''${FILE_PATH}" 1-10
        exiftool "''${FILE_PATH}"
        ;;
      *)
        bat --color=always "''${FILE_PATH}"
        ;;
    esac
  '';
in {

  home.packages = with pkgs; [
    zoxide
    starship
    direnv
    nix-index
    # For file previews
    exiftool
    mupdf
    unrar
    atool
    timg
    libarchive
  ];

  xdg.configFile.starship = {
    target = "starship.toml";
    text = ''
      add_newline = false

      [nix_shell]
      impure_msg = ""
      symbol = "❄️"

      [shlvl]
      symbol = "↕️ "
      disabled = false

      [status]
      disabled = false
    '';
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    history.expireDuplicatesFirst = false;
    history.ignoreDups = false;
    shellAliases = {
      b = "bat --paging never";
      l = "exa -lh --git";
      ll = "exa -lhT --git -L 2";
      lll = "exa -lhT --git -L 3";
      r = "ranger";
      hms = "home-manager switch";
      homed = "$EDITOR ~/.config/nixpkgs/home.nix";
      nrs = "sudo nixos-rebuild switch";
      confed = "sudo $EDITOR /etc/nixos/configuration.nix";
      dc = "docker-compose";
      t = "TERM=xterm"; # Sometimes programs refuse to run in kitty
      "куищще" = "reboot";
    };
    initExtra = ''
      setopt numericglobsort   # Sort filenames numerically when it makes sense
      setopt appendhistory     # Immediately append history instead of overwriting
      setopt histignorealldups # If a new command is a duplicate, remove the older one
      setopt autocd autopushd  # Implied cd
      autoload -U compinit # Completion
      compinit

      transfer() {
        if [ $# -eq 0 ]; then
          echo -e "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md";
          return 1;
        fi
        tmpfile=$( mktemp -t transferXXX );
        if tty -s; then
          basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g');
          curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> $tmpfile;
        else
          curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> $tmpfile ;
        fi;
          cat $tmpfile | xclip;
          cat $tmpfile;
          echo;
          rm -f $tmpfile;
      }


      o() {
        if [[ -z "$1" ]]; then
          SEARCHPATH="$(pwd)";
        else
          SEARCHPATH="$1";
        fi

        if ! [[ -a "$SEARCHPATH" ]]; then
          echo "Invalid path: $SEARCHPATH"
          return
        fi

        if ! [[ -d "$SEARCHPATH" ]]; then
          FILE="$SEARCHPATH"
        else
          FILE=$(ls "$SEARCHPATH" | fzf -0 --preview-window='right:70%' --preview="${preview-file}/bin/preview-file.sh "$SEARCHPATH"/{}")
          if [[ -z "$FILE" ]]; then
            return
          fi
          FILE="''${SEARCHPATH}/''${FILE}" 
        fi

        if [[ -z "$FILE" ]]; then
          echo "File not found"
          return
        fi

        if ! [[ -a "$FILE" ]]; then
          echo "No such file: $FILE"
          return
        fi

        if [[ -d "$FILE" ]]; then
          o "$FILE"
        else
          xdg-open "$FILE" & disown
        fi
      }

      function join_by { local d=''${1-} f=''${2-}; if shift 2; then printf %s "$f" "''${@/#/$d}"; fi; }

      function nsp {
        nix shell nixpkgs#`join_by " nixpkgs#" ''${@[@]}`
      }

      nsr() {
        nix shell nixpkgs#"$1" -c "$1"
      }


      # Speed up completions
      zstyle ':completion:*' accept-exact '*(N)'
      zstyle ':completion:*' use-cache on
      zstyle ':completion:*' cache-path ~/.zsh/cache

      # Fuzzy completions
      zstyle ':completion:*' completer _complete _match _approximate
      zstyle ':completion:*:match:*' original only
      zstyle ':completion:*:approximate:*' max-errors 1 numeric
      zstyle -e ':completion:*:approximate:*' \
              max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3))numeric)'

      bindkey '^[[A' up-line-or-search
      bindkey '^[[B' down-line-or-search
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word

      # https://unix.stackexchange.com/a/250700
      my-backward-delete-word() {
          local WORDCHARS=''${WORDCHARS/\//#}
          zle backward-delete-word
      }
      zle -N my-backward-delete-word
      bindkey '^W' my-backward-delete-word

      eval "$(dircolors ~/.dir_colors)";

      eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
      export _ZO_ECHO=1
      alias j='z'

      eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
      eval "$(${pkgs.starship}/bin/starship init zsh)"
      source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
      export PATH="''${PATH}:/home/quentin/.local/bin"
      export SSH_AUTH_SOCK="/run/user/1000/ssh-agent"
    '';
  };

}

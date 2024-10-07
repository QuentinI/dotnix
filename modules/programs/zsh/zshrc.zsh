setopt numericglobsort   # Sort filenames numerically when it makes sense
setopt appendhistory     # Immediately append history instead of overwriting
setopt histignorealldups # If a new command is a duplicate, remove the older one
setopt autocd autopushd  # Implied cd
autoload -U compinit     # Completion
compinit

# Load homebrew if exists
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)";
fi

# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Completion menu
zstyle ':completion:*' menu select

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
    local WORDCHARS=${WORDCHARS/\//#}
    zle backward-delete-word
}
zle -N my-backward-delete-word
bindkey '^W' my-backward-delete-word

export HISTFILE=~/.zsh_history
export PATH="${PATH}:/Users/${USER}/.cargo/bin"

function join_by { local d=${1-} f=${2-}; if shift 2; then printf %s "$f" "${@/#/$d}"; fi; }

function nsp {
  nix shell nixpkgs#`join_by " nixpkgs#" ${@[@]}`
}

function nsr() {
  nix shell nixpkgs#"$1" -c "$1"
}

function myip() {
  xh -b https://ipapi.co/json/
}

function transfer() {
  if [ $# -eq 0 ]; then
    echo -e "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md";
    return 1;
  fi
  tmpfile=$( mktemp -t transferXXX );
  if tty -s; then
    basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g');
    curl --progress-bar --upload-file "$1" "https://oshi.at/$basefile" >> $tmpfile;
  else
    curl --progress-bar --upload-file "-" "https://oshi.at/$1" >> $tmpfile ;
  fi;
    cat $tmpfile | xclip;
    cat $tmpfile;
    echo;
    rm -f $tmpfile;
}


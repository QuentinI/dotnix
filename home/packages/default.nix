# # A list of packages requiring little to no configuration
## Just adds them to home.packages
{ pkgs, ... }:

let
  sources = import ../../nix/sources.nix;
  pkgs-release =
    import "${sources.nixpkgs-release}" { config = { allowBroken = true; }; };
in with pkgs; {
  home.packages = [
    # Command-line essentials
    atool
    unrar
    unzip
    bzip2 # Archive management
    bat
    exa
    fd
    ripgrep # Bloatware instead of ol' good unix tools
    htop
    most
    pv
    tldr
    lf
    file
    git
    telnet
    picocom
    gopass
    github-cli

    ## Compilers/interpreters
    (python3.withPackages (ps:
      with ps; [
        virtualenv
        pip
        tkinter
        python-language-server
        # Broken
        # pyls-mypy
        # pyls-isort
        # pyls-black
        setuptools
        numpy
        scipy
        matplotlib
        pytest
      ]))
    poetry
    pipenv
    (python2.withPackages (ps: with ps; [ virtualenv pip ]))
    (ghc.withPackages (ps: with ps; [ tidal ]))
    nodejs
    yarn
    rustup
    llvm
    llvmPackages.clang-unwrapped
    elixir
    shellcheck
    nixfmt
    gcc

    jetbrains.jdk # Jetbrains JDK is more convinient generally

    ## Docker
    docker
    docker_compose

    ## Editors and stuff
    (emacs.override { withXwidgets = true; })
    irony-server # TODO move to own package with deps
    jetbrains.clion
    # jetbrains.idea-ultimate
    pencil # UML editing
    insomnia # API testing
    anki

    ## Games
    steam
    xonotic
    wesnoth

    ## Image editing
    imagemagick
    pinta
    krita
    gimp
    ffmpeg

    ## Messaging
    discord
    wire-desktop
    gitter
    zoom-us
    vk-messenger
    skype

    ## Media
    lollypop
    (gnome-podcasts.overrideAttrs (base:
      with pkgs.gst_all_1; {
        buildInputs = base.buildInputs ++ [ gst-plugins-good gst-plugins-ugly ];
      }))
    feh
    mpv
    pulseeffects
    sox
    spotify

    ## Documents
    texlive.combined.scheme-full
    calibre
    zathura
    libreoffice-unwrapped
    pdftk
    pandoc

    ## Browsing
    firefox
    chromium

    ## Download management
    aria2
    uget
    qbittorrent

    ## Dictionaries
    hunspell
    hunspellDicts.en-us
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    aspellDicts.ru

    # Screen
    arandr

    # Sound
    pavucontrol
    (speechd.override { withPulse = true; })

    # Generative music
    # I'm kinda tired of compiling it over and over
    # jack2Full
    # sc-plugins
    # supercollider

    #System management
    # Boom! Doesn't build on master
    # anydesk
    ntfsprogs
    ntfs3g
    # Nixos housekeeping
    # FIXME: broken, restore to pkgs
    pkgs-release.vulnix # NixOS vulnerability scanner
    nox # Apt-cache, kinda
    niv
    nix-diff
    cachix

    # Unsorted. Fuck it.
    # TODO maybe?..
    binutils
    blueman
    gnumake
    gnupg
    gnutls
    gparted
    highlight
    ifuse
    inotify-tools
    jmtpfs
    networkmanagerapplet
    patchelf
    playerctl
    psmisc
    shared-mime-info
    unclutter
    virtmanager
    stlink # For work

    # Fixes "failed to commit changes to dconf" issues
    gnome3.dconf
  ];
}


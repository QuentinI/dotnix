{ config, pkgs, ... }:

pkgs.python3Packages.buildPythonApplication rec {
  pname = "mopidy-local";
  version = "3.1.1";

  src = pkgs.fetchFromGitHub {
    owner = "mopidy";
    repo = "mopidy-local";
    rev = "v${version}";
    sha256 = "0r2jfjgi8qhnm9vsrpfjy7hgdsbb8fxb82h14rgvs5f9sh26ksry";
  };

  buildInputs = with pkgs.gst_all_1; [
    gst-plugins-base
    gst-plugins-good
    gst-plugins-ugly
    gst-plugins-bad
    pkgs.glib-networking
    pkgs.gobject-introspection
  ];

  propagatedBuildInputs = with pkgs; [
    mopidy
    pkgs.python3.pkgs.configobj
    pkgs.python3.pkgs.uritools
    pkgs.python3.pkgs.pytest
  ];
}

{
  lib,
  fetchFromGitHub,
  naerskUnstable,
  makeWrapper,
  pkg-config,
  perl,
  openssl,
  python3,
  runCommand,
  napalm,
  nodejs_latest,
  libsForQt5,
  xdg-utils,
  stdenv,
  cargo,
}@inputs:

let
  version = "unstable-2022-03-21";
  sources = import ./sources.nix inputs;
  py-deps = import ./py-deps.nix inputs;
in
rec {
  aw-core = python3.pkgs.buildPythonPackage rec {
    pname = "aw-core";
    inherit version;

    format = "pyproject";

    src = "${sources.activitywatch}/aw-core";

    nativeBuildInputs = [
      python3.pkgs.poetry
    ];

    propagatedBuildInputs = with python3.pkgs; [
      jsonschema
      peewee
      appdirs
      iso8601
      python-json-logger
      pymongo
      strict-rfc3339
      rfc3339-validator
      tomlkit
      deprecation

      py-deps.timeslot
      py-deps.TakeTheTime
    ];

    postPatch = ''
      sed -E 's#python-json-logger = "\^0.1.11"#python-json-logger = "^2.0"#g' -i pyproject.toml
    '';

    meta = with lib; {
      description = "Core library for ActivityWatch";
      homepage = "https://github.com/ActivityWatch/aw-core";
      maintainers = with maintainers; [ jtojnar ];
      license = licenses.mpl20;
    };
  };

  aw-client = python3.pkgs.buildPythonPackage rec {
    pname = "aw-client";
    inherit version;

    format = "pyproject";

    src = "${sources.activitywatch}/aw-client";

    nativeBuildInputs = [
      python3.pkgs.poetry
    ];

    propagatedBuildInputs = with python3.pkgs; [
      aw-core
      requests
      persist-queue
      click
    ];

    postPatch = ''
      sed -E 's#click = "\^7.1.1"#click = "^8.0"#g' -i pyproject.toml
    '';

    meta = with lib; {
      description = "Client library for ActivityWatch";
      homepage = "https://github.com/ActivityWatch/aw-client";
      maintainers = with maintainers; [ jtojnar ];
      license = licenses.mpl20;
    };
  };

  aw-qt = python3.pkgs.buildPythonApplication rec {
    pname = "aw-qt";
    inherit version;

    format = "pyproject";

    src = "${sources.activitywatch}/aw-qt";

    nativeBuildInputs = [
      python3.pkgs.poetry
      python3.pkgs.pyqt5 # for pyrcc5
      libsForQt5.wrapQtAppsHook
      xdg-utils
    ];

    propagatedBuildInputs = with python3.pkgs; [
      aw-core
      pyqt5
      click
    ];

    # Prevent double wrapping
    dontWrapQtApps = true;

    postPatch = ''
      sed -E 's#click = "\^7.1.2"#click = "^8.0"#g' -i pyproject.toml
      sed -E 's#PyQt5 = "5.15.6"#PyQt5 = "^5.15.2"#g' -i pyproject.toml
    '';

    preBuild = ''
      HOME=$TMPDIR make aw_qt/resources.py
    '';

    postInstall = ''
      install -Dt $out/etc/xdg/autostart resources/aw-qt.desktop
      xdg-icon-resource install --novendor --size 32 media/logo/logo.png activitywatch
      xdg-icon-resource install --novendor --size 512 media/logo/logo.png activitywatch
    '';

    preFixup = ''
      makeWrapperArgs+=(
        "''${qtWrapperArgs[@]}"
      )
    '';

    meta = with lib; {
      description = "Tray icon that manages ActivityWatch processes, built with Qt";
      homepage = "https://github.com/ActivityWatch/aw-qt";
      maintainers = with maintainers; [ jtojnar ];
      license = licenses.mpl20;
    };
  };

  aw-server-rust = naerskUnstable.buildPackage {
    name = "aw-server-rust";
    inherit version;

    src = "${sources.activitywatch}/aw-server-rust";
    root = "${sources.activitywatch}/aw-server-rust";

    nativeBuildInputs = [
      pkg-config
      perl
    ];

    buildInputs = [
      openssl
    ];

    overrideMain = attrs: {
      nativeBuildInputs = attrs.nativeBuildInputs or [ ] ++ [
        makeWrapper
      ];

      postFixup =
        attrs.postFixup or ""
        + ''
          wrapProgram "$out/bin/aw-server" \
            --prefix XDG_DATA_DIRS : "$out/share"
          mkdir -p "$out/share/aw-server"
          ln -s "${aw-webui}" "$out/share/aw-server/static"
        '';
    };

    meta = with lib; {
      description = "Cross-platform, extensible, privacy-focused, free and open-source automated time tracker";
      homepage = "https://github.com/ActivityWatch/aw-server-rust";
      maintainers = with maintainers; [ jtojnar ];
      platforms = platforms.linux;
      license = licenses.mpl20;
    };
  };

  aw-watcher-window-wayland = naerskUnstable.buildPackage {
    name = "aw-window-wayland";
    version = "0.1.0";

    src = sources.aw-watcher-window-wayland;
    root = sources.aw-watcher-window-wayland;

    nativeBuildInputs = [
      pkg-config
    ];

    buildInputs = [
      openssl
    ];

    meta = with lib; {
      description = " WIP window and afk watcher for wayland ";
      homepage = "https://github.com/activitywatch/aw-watcher-window-wayland";
      maintainers = with maintainers; [ quentini ];
      platforms = platforms.linux;
      license = licenses.mpl20;
    };
  };

  aw-watcher-afk = python3.pkgs.buildPythonApplication rec {
    pname = "aw-watcher-afk";
    inherit version;

    format = "pyproject";

    src = "${sources.activitywatch}/aw-watcher-afk";

    nativeBuildInputs = [
      python3.pkgs.poetry
    ];

    propagatedBuildInputs = with python3.pkgs; [
      aw-client
      xlib
      pynput
    ];

    postPatch = ''
      sed -E 's#python-xlib = \{ version = "\^0.28"#python-xlib = \{ version = "^0.29"#g' -i pyproject.toml
    '';

    meta = with lib; {
      description = "Watches keyboard and mouse activity to determine if you are AFK or not (for use with ActivityWatch)";
      homepage = "https://github.com/ActivityWatch/aw-watcher-afk";
      maintainers = with maintainers; [ jtojnar ];
      license = licenses.mpl20;
    };
  };

  aw-webui =
    let
      # Node.js used by napalm.
      nodejs = nodejs_latest;

      installHeadersForNodeGyp = ''
        mkdir -p "$HOME/.cache/node-gyp/${nodejs.version}"
        # Set up version which node-gyp checks in <https://github.com/nodejs/node-gyp/blob/4937722cf597ccd1953628f3d5e2ab5204280051/lib/install.js#L87-L96> against the version in <https://github.com/nodejs/node-gyp/blob/4937722cf597ccd1953628f3d5e2ab5204280051/package.json#L15>.
        echo 9 > "$HOME/.cache/node-gyp/${nodejs.version}/installVersion"
        # Link node headers so that node-gyp does not try to download them.
        ln -sfv "${nodejs}/include" "$HOME/.cache/node-gyp/${nodejs.version}"
      '';

      stopNpmCallingHome = ''
        # Do not try to find npm in napalm-registry –
        # it is not there and checking will slow down the build.
        npm config set update-notifier false
        # Same for security auditing, it does not make sense in the sandbox.
        npm config set audit false
      '';
    in
    napalm.buildPackage "${sources.activitywatch}/aw-server-rust/aw-webui" {
      nativeBuildInputs = [
        # deasync uses node-gyp
        python3
      ];

      npmCommands = [
        # Let’s install again, this time running scripts.
        "npm install --loglevel verbose"

        # Build the front-end.
        "npm run build"
      ];

      postConfigure = ''
        # configurePhase sets $HOME
        ${installHeadersForNodeGyp}
        ${stopNpmCallingHome}
      '';

      installPhase = ''
        runHook preInstall
        mv dist $out
        runHook postInstall
      '';
    };
}

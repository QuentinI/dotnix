{
  darwin =
    { ... }:
    {
      launchd.agents.FirefoxEnv = {
        serviceConfig.ProgramArguments = [
          "/bin/sh"
          "-c"
          "launchctl setenv MOZ_LEGACY_PROFILES 1; launchctl setenv MOZ_ALLOW_DOWNGRADE 1"
        ];
        serviceConfig.RunAtLoad = true;
      };
    };
  home =
    {
      config,
      pkgs,
      nur,
      ...
    }:
    let
      # https://github.com/nix-community/home-manager/issues/6955#issuecomment-2878146879
      package = pkgs.librewolf;
    in
    {
      xdg.configFile.tridactylrc = {
        source = ./tridactylrc;
        target = "tridactyl/tridactylrc";
      };

      home.packages = [ package ];

      programs.librewolf = {
        enable = true;
        package = package.overrideAttrs (_: {
          override = _: package;
        });
        profileVersion = null;
        profiles = {
          default = {
            id = 0;
            isDefault = true;

            extensions.packages = with nur.repos.rycee.firefox-addons; [
              # Anti-Ad
              ublock-origin
              sponsorblock

              # Anti-tracking
              clearurls
              canvasblocker
              decentraleyes

              # Anti-annoyance
              dearrow
              consent-o-matic
              terms-of-service-didnt-read

              # Stylistic
              refined-github
              stylus

              bitwarden
              metamask
              multi-account-containers
            ];

            settings = {
              # Vertical tabs
              "sidebar.revamp" = true;
              "sidebar.verticalTabs" = true;

              "privacy.clearOnShutdown.history" = false;
              "privacy.clearOnShutdown.cookies" = false;
              "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
              "privacy.resistFingerprinting" = false;
              "privacy.fingerprintingProtection.overrides" = "+AllTargets,-CSSPrefersColorScheme,-MediaDevices";
              "webgl.disabled" = false;
              "extensions.autoDisableScopes" = 0;
              "browser.aboutConfig.showWarning" = false;

              "geo.wifi.uri" = "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";
              "browser.safebrowsing.downloads.remote.enabled" = false;
              "browser.safebrowsing.enabled" = false;

              # Disable auto-update
              "app.update.enabled" = false;

              # Disable this vulnerable clusterfuck
              "pdfjs.disabled" = true;

              # Theme
              # "ui.systemUsesDarkTheme" = if config.theme.base16.kind == "dark" then 1 else 0;
              # "devtools.theme" = "${config.theme.base16.kind}";
              # HiDPi
              "layout.css.devPixelsPerPx" = "-1";

              # Homepage
              "browser.startup.homepage" = "duckduckgo.com";
              # Make Ctrl-Tab just switch you to the next tab
              "browser.ctrlTab.recentlyUsedOrder" = false;
              # I don't usually want to close my browser...
              "browser.tabs.closeWindowWithLastTab" = false;
              # ...but when I do, I really do
              "browser.tabs.warnOnClose" = false;
              # Resume session automatically
              "browser.sessionstore.resume_session_once" = true;

              # Okay, Mozilla, this one was a real shit move
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

            };
            # UI styling
            userChrome = builtins.readFile ./userChrome.css;
          };
        };
      };
    };
}

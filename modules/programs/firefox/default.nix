{ config, pkgs, nur, ... }:
let
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
    package = package;
    profiles = {
      default = {
        isDefault = true;

        extensions = with nur.repos.rycee.firefox-addons; [
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
          "webgl.disabled" = false;
          "extensions.autoDisableScopes" = 0;
          "browser.aboutConfig.showWarning" = false;

          "geo.wifi.uri" =
            "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";
          "browser.safebrowsing.downloads.remote.enabled" = false;
          "browser.safebrowsing.enabled" = false;

          # Disable auto-update
          "app.update.enabled" = false;

          # Disable this vulnerable clusterfuck
          "pdfjs.disabled" = true;

          # Theme
          "ui.systemUsesDarkTheme" =
            if config.theme.base16.kind == "dark" then 1 else 0;
          "devtools.theme" = "${config.theme.base16.kind}";
          # HiDPi
          "layout.css.devPixelsPerPx" = "2";

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
}

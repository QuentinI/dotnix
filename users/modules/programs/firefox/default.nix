{ config, pkgs, ... }:

{
  xdg.configFile.tridactylrc = {
    source = ./tridactylrc;
    target = "tridactyl/tridactylrc";
  };

  home.packages = [ pkgs.firefox ];

  programs.firefox = {
    enable = true;
    profiles = {
      default = {
        id = 0;
        isDefault = true;

        # Hardening cherry-picked from https://github.com/pyllyukko/user.js
        settings = {
          # Disable all Web 2.0 shit
          # Not disabled: ServiceWorkers
          "beacon.enabled" = false;
          "browser.send_pings" = false;
          "device.sensors.enable" = false;
          "dom.battery.enabled" = false;
          "dom.enable_performance" = false;
          "dom.enable_user_timing" = false;
          "dom.event.contextmenu.enabled" =
            false; # This may actually break some sites, but I hate RMB highjacking
          "dom.gamepad.enabled" = false;
          "dom.netinfo.enabled" = false;
          "dom.network.enabled" = false;
          "dom.telephony.enabled" = false;
          "dom.vr.enabled" = false;
          "dom.vibrator.enabled" =
            false; # Not working with my vibrator. 0/10 would disable again.
          "dom.webnotifications.enabled" = false;
          "media.webspeech.recognition.enable" = false;

          # WebRTC leaks internal IP
          "media.peerconnection.ice.default_address_only" = true;
          "media.peerconnection.ice.no_host" = true;

          # JS leaks locale
          "javascript.use_us_english_locale" = true;

          # Disable telemetry and telemetry and telemetry and...
          # How many more of this shit is there?
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.server" = "data:,";
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.updatePing.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.hybridContent.enabled" = false;
          "experiments.supported" = false;
          "experiments.enabled" = false;
          "experiments.manifest.uri" = "";
          "network.allow-experiments" = false;
          "breakpad.reportURL" = "";
          "browser.tabs.crashReporting.sendReport" = false;
          "browser.crashReports.unsubmittedCheck.enabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.healthreport.service.enabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "browser.discovery.enabled" = false;
          "browser.selfsupport.url" = "";
          "loop.logDomains" = false;
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry.ping.endpoint" = "";
          "browser.aboutHomeSnippets.updateUrl" = "";
          "browser.newtabpage.activity-stream.asrouter.providers.snippets" = "";
          "browser.newtabpage.activity-stream.disableSnippets" = true;
          "browser.newtabpage.activity-stream.feeds.snippets" = false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.section.highlights.includePocket" =
            false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.feeds.discoverystreamfeed" =
            false;
          "extensions.shield-recipe-client.enabled" = false;
          "app.shield.optoutstudies.enabled" = false;

          # Disable all sorts of auto-connections
          "network.prefetch-next" = false;
          "network.dns.disablePrefetch" = true;
          "network.dns.disablePrefetchFromHTTPS" = true;
          "network.predictor.enabled" = false;
          "browser.casting.enabled" = false;
          "media.gmp-gmpopenh264.enabled" = false;
          "media.gmp-manager.url" = "";
          "network.http.speculative-parallel-limit" = 0;
          "browser.search.update" = false;

          # Spoof referrer
          "network.http.referer.spoofSource" = true;

          # Disable third-party cookies
          "network.cookie.cookieBehavior" = 1;

          # Enable first-party isolation
          "privacy.firstparty.isolate" = true;

          # Disable built-in password manager and autofill
          "signon.rememberSignons" = false;
          "browser.formfill.enable" = false;

          # Stop communicating with Google
          # I mean, I don't use Chrome for a reason
          "geo.wifi.uri" =
            "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";
          "browser.safebrowsing.downloads.remote.enabled" = false;
          "browser.safebrowsing.enabled" = false;

          # Disable auto-update
          "app.update.enabled" = false;

          # Disable this vulnerable clusterfuck
          "pdfjs.disabled" = true;

          # Disable annoying shit
          "browser.pocket.enabled" = false;
          "extensions.pocket.enabled" = false;

          # Enable DNT et al.
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.pbmode.enabled" = true;

          # Theme
          "ui.systemUsesDarkTheme" = if config.theme.base16.kind == "dark" then 1 else 0;
          "devtools.theme" = "${config.theme.base16.kind}";
          # I'm myopic
          "layout.css.devPixelsPerPx" = "1.2";

          # Homepage
          # TODO: set a default search engine somehow?
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
      # For site-breaking prefs debugging
      clean = {
        id = 1;
        isDefault = false;

        settings = { };
      };
    };
  };
}

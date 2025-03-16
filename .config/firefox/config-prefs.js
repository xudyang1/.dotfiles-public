/* vim: set fileformat=unix */
// AutoConfig file must use Unix end-of-line (LF), even on Windows systems with Firefox 60 or higher
// This file should be placed at %Mozilla Firefox%/defaults/pref/

try {
  pref("general.config.filename", "config.js");
  pref("general.config.obscure_value", 0);
  pref("general.config.sandbox_enabled", false);

  // about:config disble warning
  pref("browser.aboutConfig.showWarning", false);

  // == Custom ===
  // TODO: not being set
  // view pdf in firefox when clicking `Open in firefox`
  pref("browser.download.open_pdf_attachments_inline", true);
  // enable tab groups
  pref("browser.tabs.groups.enabled", true);
  // vertical tab bar
  pref("sidebar.revamp", true);
  pref("sidebar.verticalTabs", true);
  // sidebar on left
  pref("sidebar.position_start", true);
  // sidebar additional tools
  pref("sidebar.main.tools", "aichat,syncedtabs,history,bookmarks");

  // prevent showing top bar when pressing alt key
  pref("ui.key.menuAccessKeyFocuses", false);

  // disable full screen animation
  pref("full-screen-api.transition-duration.enter", "0 0");
  pref("full-screen-api.transition-duration.leave", "0 0");
  pref("full-screen-api.warning.delay", -1);
  pref("full-screen-api.warning.timeout", 0);

  // allow websites to ask you for your location
  pref("permissions.default.geo", 0);
  // allow websites to ask you to receive site notifications
  pref("permissions.default.desktop-notification", 0);

  // show weather on New Tab page
  pref("browser.newtabpage.activity-stream.showWeather", true);

  // only sharpen scrolling
  pref("general.smoothScroll", false);
  // Firefox Nightly only:
  // [1] https://bugzilla.mozilla.org/show_bug.cgi?id=1846935
  // pref("general.smoothScroll.msdPhysics.enabled", false); // [FF122+ Nightly]

  // urlbar
  pref("browser.urlbar.trimHttps", true);
  pref("browser.urlbar.quicksuggest.enabled", false);

  // === Betterfox common override ===
  // improve font rendering by using DirectWrite everywhere like Chrome [WINDOWS]
  pref("gfx.font_rendering.cleartype_params.rendering_mode", 5);
  pref("gfx.font_rendering.cleartype_params.cleartype_level", 100);
  pref(
    "gfx.font_rendering.cleartype_params.force_gdi_classic_for_families",
    "",
  );
  pref("gfx.font_rendering.directwrite.use_gdi_table_loading", false);

  // restore Top Sites on New Tab page
  // pref("browser.newtabpage.activity-stream.feeds.topsites", true);
  // remove default Top Sites (Facebook, Twitter, etc.)
  // This does not block you from adding your own.
  // pref("browser.newtabpage.activity-stream.default.sites", "");
  // remove sponsored content on New Tab page
  pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false); // Sponsored shortcuts
  pref("browser.newtabpage.activity-stream.feeds.section.topstories", false); // Recommended by Pocket
  pref("browser.newtabpage.activity-stream.showSponsored", false); // Sponsored Stories

  // disk avoidance
  pref("browser.privatebrowsing.forceMediaMemoryCache", true);
  // minimum interval (in ms) between session save operations
  pref("browser.sessionstore.interval", 60000);
  // disk cache
  pref("browser.cache.jsbc_compression_level", 3);

  // crash reports
  pref("breakpad.reportURL", "");
  pref("browser.tabs.crashReporting.sendReport", false);
  pref("browser.crashReports.unsubmittedCheck.autoSubmit2", false);

  // detection
  // pref("captivedetect.canonicalURL", "");
  // pref("network.captive-portal-service.enabled", false);
  // pref("network.connectivity-service.enabled", false);

  // cookie banner handling
  pref("cookiebanners.service.mode", 1);
  pref("cookiebanners.service.mode.privateBrowsing", 1);

  // disable UITour backend
  pref("browser.uitour.enabled", false);

  // telemetry
  pref("datareporting.policy.dataSubmissionEnabled", false);

  // speculative loading
  pref("network.dns.disablePrefetch", true);
  pref("network.dns.disablePrefetchFromHTTPS", true);
  pref("network.prefetch-next", false);
  pref("network.predictor.enabled", false);
  pref("network.predictor.enable-prefetch", false);
} catch (err) {
  displayError(
    "%Mozilla Firefox%/defaults/pref/config-pref.js caught error: ",
    err,
  );
}

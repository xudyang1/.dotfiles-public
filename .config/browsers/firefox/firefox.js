/* vim: set fileformat=unix filetype=javascript: */
// IMPORTANT: Start your code on the 2nd line.
// firefox.cfg (JS) set via general.config.filename
// Place at firefox install root with the executable:
//   - Windows: C:/Program Files/Mozilla Firefox/firefox.js
//   - Linux: /usr/lib/firefox/firefox.js or /etc/firefox/firefox.js
// References:
// https://support.mozilla.org/kb/customizing-firefox-using-autoconfig
// https://superuser.com/questions/1271147/1785959#1785959
// https://support.mozilla.org/en-US/questions/1367908
// https://support.mozilla.org/en-US/questions/1242189
// Debug, DevTools:
// https://firefox-source-docs.mozilla.org/devtools-user/browser_toolbox

// @deprecated: TypeError: Components.utils.import is not a function
// pre-Fx117: const { Services } = Components.utils.import('resource://gre/modules/Services.jsm');
let Services = globalThis.Services;
if (!Services) {
  Services = ChromeUtils.import("resource://gre/modules/Services.jsm");
}
// const { SessionStore } = ChromeUtils.importESModule(
//   "resource:///modules/sessionstore/SessionStore.jsm"
// );
const { classes: Cc, interfaces: Ci, manager: Cm, utils: Cu } = Components;

function setupPreferences() {
  // ===== about:config =====
  // uncomment when debugging
  pref("devtools.debugger.prompt-connection", false);
  // pref("devtools.debugger.remote-enabled", true);
  // pref("devtools.chrome.enabled", true);

  // ===== about:settings =====
  // --- Home and Startup ---
  // == Startup ==
  // 0: blank page, 1: homepage, 2: last visited page, 3: open previous windows and tabs
  pref("browser.startup.page", 3);
  pref("browser.startup.autoRun", false);
  // == Firefox Home ==
  pref("browser.newtabpage.activity-stream.showSearch", true);
  // restore Top Sites on New Tab page
  pref("browser.newtabpage.activity-stream.feeds.topsites", true);
  // custom topsites
  // pref("browser.newtabpage.activity-stream.default.sites", "");
  pref("browser.newtabpage.activity-stream.topSitesRows", 2);
  pref("browser.newtabpage.activity-stream.showWeather", false);
  pref("browser.newtabpage.activity-stream.weather.temperatureUnits", "c");
  pref("browser.newtabpage.activity-stream.hideLogo", false);
  pref("browser.newtabpage.activity-stream.showWebNotifications", false);
  // disable sponsored content on New Tab page
  pref("browser.newtabpage.activity-stream.showSponsored", false);
  pref("browser.newtabpage.activity-stream.showSponsoredCheckboxes", false);
  pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
  // disable stories and recent activities
  pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
  pref("browser.newtabpage.activity-stream.feeds.section.highlights", false);
  // disable telemetry
  pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
  pref("browser.newtabpage.activity-stream.telemetry", false);
  pref(
    "browser.newtabpage.activity-stream.telemetry.privatePing.enabled",
    false,
  );
  pref(
    "browser.newtabpage.activity-stream.telemetry.privatePing.inferredInterests.enabled",
    false,
  );
  // --- Search ---
  pref("browser.search.suggest.enabled", true);
  pref("browser.search.suggest.enabled.private", true);
  // disable unused suggestions
  pref("browser.urlbar.suggest.addons", false);
  pref("browser.urlbar.suggest.amp", false);
  pref("browser.urlbar.suggest.clipboard", false);
  pref("browser.urlbar.suggest.engines", false);
  pref("browser.urlbar.suggest.importantDates", false);
  pref("browser.urlbar.suggest.mdn", false);
  pref("browser.urlbar.suggest.sports", false);
  pref("browser.urlbar.suggest.weather", false);
  pref("browser.urlbar.suggest.wikipedia", false);
  pref("browser.urlbar.suggest.yelp", false);
  pref("browser.urlbar.suggest.yelpRealtime", false);
  // disable quicksuggest from Firefox
  pref("browser.urlbar.quicksuggest.enabled", false);
  pref("browser.urlbar.quicksuggest.mlEnabled", false);
  pref("browser.urlbar.quicksuggest.online.enabled", false);
  pref("browser.urlbar.suggest.quicksuggest.all", false);
  pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);
  pref("browser.urlbar.suggest.quicksuggest.sponsored", false);
  pref("browser.urlbar.quicksuggest.dataCollection.enabled", false);
  // disable telemetry
  pref("browser.search.serpEventTelemetryCategorization.enabled", false);
  pref("browser.search.serpEventTelemetryCategorization.regionEnabled", false);
  // --- Privacy and security ---
  pref("browser.contentblocking.category", "strict");
  // DoH only
  pref("network.trr.mode", 3);
  // cloudflare provider
  pref("network.trr.uri", "https://mozilla.cloudflare-dns.com/dns-query");
  // --- Password and autofill ---
  // stop suggesting/autofilling username/email/text
  pref("browser.formfill.enable", false);
  // // disable autofill username/password in login form
  // pref("signon.autofillForms", false);
  // // disable asking "Save password?"
  // pref("signon.rememberSignons", false);
  pref("extensions.formautofill.creditCards.enabled", false);
  pref("extensions.formautofill.addresses.enabled", false);
  // --- Downloads ---
  pref("browser.download.always_ask_before_handling_new_types", true);
  pref("browser.download.autohideButton", false);
  // view pdf in firefox when clicking `Open in firefox`
  pref("browser.download.open_pdf_attachments_inline", true);
  pref("browser.download.panel.shown", true);
  pref("browser.download.useDownloadDir", false);
  // --- Tabs and browsing ---
  // vertical tab bar
  pref("sidebar.revamp", true);
  pref("sidebar.verticalTabs", true);
  pref("sidebar.position_start", true);
  pref("sidebar.main.tools", "aichat,history,bookmarks,syncedtabs");
  pref("sidebar.visibility", "hide-sidebar");
  pref("sidebar.animation.enabled", false);
  // 1: current tab, 2: new window, 3: new tab
  pref("browser.link.open_newwindow", 3);
  // false: open links in a new tab and switch to it immediately
  pref("browser.tabs.loadInBackground", true);
  // open links at the end
  pref("browser.tabs.insertAfterCurrent", false);
  pref("browser.tabs.insertAfterCurrentExceptPinned", false);
  pref("browser.tabs.insertRelatedAfterCurrent", true);
  pref("browser.ctrlTab.recentlyUsedOrder", true);
  pref("browser.ctrlTab.sortByRecentlyUsed", true);
  pref("browser.tabs.warnOnClose", false);
  // container tabs
  pref("privacy.userContext.enabled", true);
  pref("privacy.userContext.ui.enabled", true);
  pref("browser.preferences.defaultPerformanceSettings.enabled", false);
  // hardware acceleration
  pref("layers.acceleration.disabled", false);
  // disable search text when typing
  pref("accessibility.typeaheadfind", false);
  pref("accessibility.typeaheadfind.flashBar", 0);
  // disable extension recommendations
  pref(
    "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons",
    false,
  );
  // disable feature recommendations
  pref(
    "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features",
    false,
  );
  // --- accessibility ---
  // disable touch keyboard
  pref("ui.osk.enabled", false);
  // middle-click scroll
  pref("general.autoScroll", true);
  pref("general.smoothScroll", false);
  // --- AI controls ---
  // == Translation ==
  // enable entire translation function
  pref("browser.translations.enable", true);
  pref("browser.translations.select.enable", true);
  // enable `translate this` popup
  pref("browser.translations.automaticallyPopup", false);
  // setup target translation languages when selecting text and right click
  pref("browser.translations.mostRecentTargetLanguages", "en,zh-Hans");
  // pref("browser.translations.panelShown", true);
  pref("browser.ai.control.speechRecognition", "blocked");
  pref("browser.ai.control.pdfjsAltText", "blocked");
  pref("browser.ai.control.smartTabGroups", "blocked");
  pref("browser.ai.control.linkPreviewKeyPoints", "blocked");
  pref("browser.ai.control.sidebarChatbot", "blocked");
  pref("browser.ai.control.smartWindow", "blocked");
  // --- Permissions and data ---
  // 0: ask for permission
  // 1: grant permission to all sites by default
  // 2: block all sites from requesting permission
  pref("permissions.default.camera", 0);
  pref("permissions.default.microphone", 0);
  pref("permissions.default.geo", 2);
  pref("permissions.default.desktop-notification", 2);
  pref("permissions.default.xr", 2);
  // blocks pop-ups and third-party redirects
  pref("dom.disable_open_during_load", true);
  // show warning when websites try to install extensions
  pref("xpinstall.whitelist.required", true);
  // disable telemetry
  pref("datareporting.healthreport.uploadEnabled", false);
  pref("datareporting.policy.dataSubmissionEnabled", false);
  pref("datareporting.usage.uploadEnabled", false);

  // ===== misc =====
  // disable link previews
  pref("browser.ml.linkPreview.enabled", false);
  pref("browser.ml.linkPreview.longPress", false);
  // enable tab groups
  pref("browser.tabs.groups.enabled", true);
  pref("browser.shell.checkDefaultBrowser", false);
  // hide title bar
  pref("browser.tabs.inTitlebar", 1);
  pref("browser.aboutConfig.showWarning", false);
  // enable search image by Google Lens
  pref("browser.search.visualSearch.featureGate", true);
  // prevent showing top bar when pressing alt key
  pref("ui.key.menuAccessKeyFocuses", false);
  // urlbar
  pref("browser.urlbar.trimHttps", true);
  // disable full screen animation
  pref("full-screen-api.transition-duration.enter", "0 0");
  pref("full-screen-api.transition-duration.leave", "0 0");
  pref("full-screen-api.warning.delay", -1);
  pref("full-screen-api.warning.timeout", 0);
  pref("full-screen-api.transition.timeout", 0);

  // disk avoidance
  // pref("browser.privatebrowsing.forceMediaMemoryCache", true);
  // minimum interval (in ms) between session save operations
  pref("browser.sessionstore.interval", 60000);
  // disk cache
  pref("browser.cache.jsbc_compression_level", 3);

  // crash reports
  pref("breakpad.reportURL", "");
  pref("browser.tabs.crashReporting.sendReport", false);
  pref("browser.crashReports.unsubmittedCheck.autoSubmit2", false);

  // Wifi detection
  // pref("captivedetect.canonicalURL", "");
  // pref("network.captive-portal-service.enabled", false);
  // pref("network.connectivity-service.enabled", false);

  // cookie banner handling
  // 0: disabled, banners not handled automatically
  // 1: automatically reject all non-essential cookies when possible
  // 2: detect-only / report, banners still appear
  pref("cookiebanners.service.mode", 1);
  pref("cookiebanners.service.mode.privateBrowsing", 1);

  // disable UITour backend
  pref("browser.uitour.enabled", false);

  // speculative loading
  // pref("network.dns.disablePrefetch", true);
  // pref("network.dns.disablePrefetchFromHTTPS", true);
  // pref("network.prefetch-next", false);
  // pref("network.predictor.enabled", false);
  // pref("network.predictor.enable-prefetch", false);

  // pref("browser.urlbar.speculativeConnect.enabled", false);
  // pref("browser.places.speculativeConnect.enabled", false);
  // pref("dom.script_loader.external_scripts.speculative_omt_parse.enabled", false);
  // pref("network.http.speculative-parallel-limit", 0);
}

function injectCSS() {
  // without -moz-document, but may experience UI flash
  // const siteStyles = {
  //   "reddit.com": `
  //     #subgrid-container > div.main-container { display: block !important; }
  //     #right-sidebar-container { min-width: 100% !important; }
  //     #right-sidebar-contents { display: flex !important; flex-direction: column !important; width: 100% !important; }
  //     #right-sidebar-contents > div:nth-of-type(-n+2) { display: none !important; }
  //   `,
  //   "stackoverflow.com": `
  //     #sidebar { display: none !important; }
  //     #mainbar { width: 100% !important; }
  //   `,
  //   "stackexchange.com": `
  //     #sidebar { display: none !important; }
  //     #mainbar { width: 100% !important; }
  //   `,
  //   "superuser.com": `
  //     #sidebar { display: none !important; }
  //     #mainbar { width: 100% !important; }
  //   `,
  // };
  // // 2. Create the script that will run inside every page
  // // We use a "data:" URI to pass the code to the content process
  // let frameScript =
  //   "data:application/javascript," +
  //   encodeURIComponent(`
  //   (() => {
  //     const siteStyles = ${JSON.stringify(siteStyles)};
  //
  //     addEventListener("DOMContentLoaded", (event) => {
  //       const doc = event.target;
  //       const host = doc.location.host;
  //
  //       for (let domain in siteStyles) {
  //         if (host.includes(domain)) {
  //           const style = doc.createElement("style");
  //           style.textContent = siteStyles[domain];
  //           doc.documentElement.appendChild(style);
  //           break;
  //         }
  //       }
  //     }, true);
  //   })();
  // `);
  // // 3. Register the script globally
  // // This tells Firefox: "Run this script in every single tab/frame that opens"
  // if (!Services.mm) {
  //   throw new Error("Services.mm is undefined");
  // }
  // Services.mm.loadFrameScript(frameScript, true);

  // === -moz-document may be restricted by firefox in the future
  // inject site-specific CSS
  const sss = Cc["@mozilla.org/content/style-sheet-service;1"].getService(
    Ci.nsIStyleSheetService,
  );
  const ios = Cc["@mozilla.org/network/io-service;1"].getService(
    Ci.nsIIOService,
  );

  const css = `
  @-moz-document domain("reddit.com") {
    #subgrid-container > div.main-container { display: block !important; }
    #right-sidebar-container { min-width: 100% !important; }
    #right-sidebar-contents { display: flex !important; flex-direction: column !important; width: 100% !important; }
    #right-sidebar-contents > div:nth-of-type(-n+2) { display: none !important; }
  }
  @-moz-document domain("stackoverflow.com") {
    #sidebar { display: none !important; }
    #mainbar { width: 100% !important; }
  }
  @-moz-document domain("stackexchange.com") {
    #sidebar { display: none !important; }
    #mainbar { width: 100% !important; }
  }
  @-moz-document domain("superuser.com") {
    #sidebar { display: none !important; }
    #mainbar { width: 100% !important; }
  }
  `;

  const uri = ios.newURI(
    "data:text/css;charset=utf-8," + encodeURIComponent(css),
    null,
    null,
  );
  if (!sss.sheetRegistered(uri, sss.USER_SHEET)) {
    sss.loadAndRegisterSheet(uri, sss.USER_SHEET);
  }
}

function addShortcuts() {
  // add custom shortcut to toggle sidebar
  Services.mm.addMessageListener("Shortcut:ToggleSidebar", (msg) => {
    let win = Services.wm.getMostRecentWindow("navigator:browser");
    if (win && msg.target === win.gBrowser.selectedBrowser) {
      win.SidebarController.handleToolbarButtonClick();
    }
  });
  // content process
  let frameScript =
    "data:application/javascript," +
    encodeURIComponent(`
    (() => {
      // if there's no content window or it's a non-HTML page (like a background conduit), exit early.
      if (typeof content === "undefined" || !content || !content.document) return;
      // use 'false' to capture the event after the page/extension
      addEventListener("keydown", (e) => {
        // guard: only fire from the main tab, not every small iframe
        if (content !== content.top) return;
        if (!content.document.hasFocus()) return;
        // <C-,>: toggle sidebar
        if (e.ctrlKey && e.code === "Comma" && !e.defaultPrevented) {
          try{
            // send signal to the UI process
            sendAsyncMessage("Shortcut:ToggleSidebar");
          }catch(error){
            // silence conduit errors
          }
        }
      }, false);
    })();
  `);
  Services.mm.loadFrameScript(frameScript, true);
}

// window scope, runs per window
function customizeBrowserUI(window) {
  // remove "reserved" to let extensions override default shortcuts
  const reservedKeys = [
    "key_newNavigator", // <C-n>
    "key_newNavigatorTab", // <C-t>
    "key_close", // <C-w>
    // additional reserved keys
    // "key_closeWindow", // <C-S-w>
    // "key_quitApplication", // <C-S-q>
    // "key_privatebrowsing", // <C-S-p>
  ];
  for (const keyId of reservedKeys) {
    const keyCommand = window.document.getElementById(keyId);
    if (!keyCommand) {
      throw new Error(`autoconfig: ${keyId} not found.`);
    }
    keyCommand.removeAttribute("reserved");
  }

  // allow single ESC in URL bar to refocus page
  const URLBar = window.document.getElementById("urlbar-input");
  // const URLBar = window.gURLBar;
  if (!URLBar) {
    throw new Error("autoconfig: #urlbar-input not found.");
  }
  URLBar.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
      window.gBrowser.selectedBrowser.focus();
      event.stopPropagation();
      event.preventDefault();
    }
  });
  // hide findbar when focusing urlbar
  URLBar.addEventListener("focus", () => {
    if (window.gFindBar && !window.gFindBar.hidden) {
      window.gFindBar.close();
    }
  });

  // float the firefox vertical sidebar over page content
  const SidebarElementIds = [
    "sidebar-container",
    "sidebar-launcher-splitter",
    "sidebar-box",
    "sidebar-splitter",
  ];
  const sidebarElements = {};
  for (const id of SidebarElementIds) {
    sidebarElements[id] = window.document.getElementById(id);
    if (!sidebarElements[id]) {
      throw new Error(`autoconfig: #${id} not found.`);
    }
  }
  SidebarElementIds.push("placeholder");
  sidebarElements["placeholder"] = window.document.createElement("div");

  const wrapper = window.document.createElement("div");
  const sidebarContainer = sidebarElements[SidebarElementIds[0]];
  sidebarContainer.parentNode.insertBefore(wrapper, sidebarContainer);
  for (const id of SidebarElementIds) {
    wrapper.appendChild(sidebarElements[id]);
  }

  const LEFT_SIDEBAR_PREF = "sidebar.position_start";

  function customSidebarFromPref() {
    const leftSidebar = Services.prefs.getBoolPref(LEFT_SIDEBAR_PREF, true);
    const wrapperStyles = {
      display: "flex",
      flex: "1",
      order: leftSidebar ? "1" : "2",
      position: "absolute",
      top: "0",
      left: leftSidebar ? "0" : "auto",
      right: leftSidebar ? "auto" : "0",
      height: "100%",
      width: "auto",
      "z-index": "9999",
      "background-color": "var(--sidebar-background-color)",
      "box-shadow": "2px 0 5px rgba(0, 0, 0, 0.2)",
    };
    for (const [prop, value] of Object.entries(wrapperStyles)) {
      wrapper.style.setProperty(prop, value, "important");
    }
    const idsByPosition = leftSidebar
      ? SidebarElementIds
      : [...SidebarElementIds].reverse();
    for (const [index, id] of idsByPosition.entries()) {
      sidebarElements[id].style.setProperty("order", index + 1, "important");
    }
  }
  customSidebarFromPref();
  const sidebarPrefObserver = {
    observe(_subject, topic, data) {
      if (topic === "nsPref:changed" && data === LEFT_SIDEBAR_PREF) {
        customSidebarFromPref();
      }
    },
  };
  Services.prefs.addObserver(LEFT_SIDEBAR_PREF, sidebarPrefObserver);
  window.addEventListener("unload", () => {
    Services.prefs.removeObserver(LEFT_SIDEBAR_PREF, sidebarPrefObserver);
  });
}

function onWindowCreated(subject, topic) {
  if (topic !== "chrome-document-global-created") {
    return;
  }

  const window = subject;
  if (window.location.href !== "chrome://browser/content/browser.xhtml") {
    return;
  }

  // wait for full browser startup
  Services.obs.addObserver(function delayedStartupObserver(_window, _topic) {
    if (_window === window) {
      Services.obs.removeObserver(delayedStartupObserver, _topic);
      customizeBrowserUI(window);
    }
  }, "browser-delayed-startup-finished");
}

try {
  if (!Services.appinfo.inSafeMode) {
    // global
    setupPreferences();
    injectCSS();
    addShortcuts();
    // window local
    Services.obs.addObserver(onWindowCreated, "chrome-document-global-created");
  }
} catch (error) {
  // Debug errors:
  // 1. In about:config, enable:
  //   - devtools.debugger.remote-enabled
  //   - devtools.chrome.enabled
  // 2. In about:support, click "Clear startup cache..."
  // 3. Restart firefox, press CTRL+SHIFT+ALT+I to open the Browser Toolbox
  Cu.reportError(
    `An error occurred when running FIREFOX_ROOT/firefox.cfg.
Message: ${error.message}\nTrace: ${error.stack}`,
  );
  displayError(
    null,
    `An error occurred when running FIREFOX_ROOT/firefox.cfg.
Message: ${error.message}\nTrace: ${error.stack}`,
  );
}

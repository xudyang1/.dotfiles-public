// IMPORTANT: Start your code on the 2nd line.
// This file should be placed at the top level of firefox directory (directory that contains firefox executable)
//   - Windows: 'C:/Program Files/Mozilla Firefox/config.js'
//   - Linux: '/etc/firefox/config.js'
// @link: https://support.mozilla.org/en-US/kb/customizing-firefox-using-autoconfig
// @link: https://superuser.com/questions/1271147/change-key-bindings-keyboard-shortcuts-in-firefox-57/1785959#1785959
// @link: https://support.mozilla.org/en-US/questions/1367908
// @link: https://support.mozilla.org/en-US/questions/1242189
// @link: https://firefox-source-docs.mozilla.org/devtools-user/browser_toolbox/index.html

// For remote file:
// @link: https://bugzilla.mozilla.org/show_bug.cgi?id=1468702
// pref("autoadmin.global_config_url","https://yourdomain.com/autoconfigfile.js");
try {
  let { classes: Cc, interfaces: Ci, manager: Cm } = Components;
  const Services =
    globalThis.Services ||
    ChromeUtils.import("resource://gre/modules/Services.jsm").Services;
  // TODO: TypeError: Components.utils.import is not a function
  // const { SessionStore } = Components.utils.import(
  //   "resource:///modules/sessionstore/SessionStore.jsm",
  // );
  function ConfigJS() {
    Services.obs.addObserver(this, "chrome-document-global-created", false);
  }
  ConfigJS.prototype = {
    observe: function (aSubject) {
      aSubject.addEventListener("DOMContentLoaded", this, { once: true });
    },
    handleEvent: function (aEvent) {
      let document = aEvent.originalTarget;
      let window = document.defaultView;
      let location = window.location;
      if (
        /^(chrome:(?!\/\/(global\/content\/commonDialog|browser\/content\/webext-panels)\.x?html)|about:(?!blank))/i.test(
          location.href,
        )
      ) {
        if (window._gBrowser) {
          // Place your keyboard shortcut changes here
          // for firenvim
          const reserved_keys = [
            "key_newNavigator", // <C-n>
            "key_newNavigatorTab", // <C-t>
            "key_close", // <C-w>
            // additional reserved keys
            "key_closeWindow", // <C-S-w>
            "key_quitApplication", // <C-S-q>
            "key_privatebrowsing", // <C-S-p>
          ];
          reserved_keys.forEach((keyId) => {
            const keyCommand = window.document.getElementById(keyId);
            if (keyCommand !== undefined) {
              // keyCommand.removeAttribute("reserved");
              keyCommand.setAttribute("reserved", "false");
            }
          });

          // Escape in url bar to focus page
          const urlBar = window.document.getElementById("urlbar-input");
          const focusPage = (event) => {
            if (event.key === "Escape") {
              window.gBrowser.selectedBrowser.messageManager.loadFrameScript(
                "data:,content.focus();",
                true,
              );
            }
          };
          urlBar.addEventListener("keydown", focusPage);

          // disable full-screen (F11) animation
          let style = window.document.createElement("style");
          style.type = "text/css";
          style.innerHTML =
            "[fullscreenShouldAnimate]{transition: none !important;}";
          window.document
            .getElementById("navigator-toolbox")
            .appendChild(style);
        }
      }
    },
  };
  if (!Services.appinfo.inSafeMode) {
    new ConfigJS();
  }
} catch (ex) {
  Services.prompt.alert(
    null,
    "AutoConfig",
    "Exception caught. Please check autoconfig file: %Mozilla Firefox%/config.js.",
  );
  Services.prompt.alert(null, "AutoConfig", ex);
  // To see error, go to about:config enable
  //   - devtools.debugger.remote-enabled
  //   - devtools.chrome.enabled
  // Then go to about:support, click `Clear startup cache...`. After restarting firefox, check devtools console.
}

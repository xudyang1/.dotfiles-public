/* vim: set fileformat=unix filetype=javascript: */
// autoconfig.js must use LF (Unix EOL)
// Place at FIREFOX_ROOT/defaults/pref/:
//   - Windows: C:/Program Files/Mozilla Firefox/defaults/pref/autoconfig.js
//   - Linux:
//     /usr/lib/firefox/defaults/pref/autoconfig.js, or
//     /etc/firefox/defaults/pref/autoconfig.js

// autoconfig.js manages general.config.* and autoadmin.*
pref("general.config.filename", "firefox.js");
pref("general.config.obscure_value", 0);
// enable privileged js code in firefox.cfg
pref("general.config.sandbox_enabled", false);

// Centralized Management (remote autconfig)
// @see: https://bugzilla.mozilla.org/show_bug.cgi?id=1468702
// When Firefox starts:
// 1. autoconfig.js loads first.
// 2. Firefox reads your pref("autoadmin.global_config_url", ...).
// 3. Firefox downloads the remote JS file (autoconfigfile.js).
// 4. The remote file is executed AFTER local firefox.cfg.
// 5. Remote file can also use:
//    - defaultPref()
//    - pref()
//    - lockPref()
//    - or JS (if sandbox disabled)
// pref("autoadmin.global_config_url","https://yourdomain.com/autoconfig.js");
// pref("autoadmin.refresh_interval", 3600);

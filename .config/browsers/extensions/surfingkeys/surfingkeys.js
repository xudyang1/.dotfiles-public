const {
  aceVimMap,
  addVimMapKey,
  addCommand,
  mapkey,
  imap,
  iunmap,
  imapkey,
  lmap,
  vmap,
  vmapkey,
  map,
  unmap,
  unmapAllExcept,
  vunmap,
  cmap,
  addSearchAlias,
  removeSearchAlias,
  isElementPartiallyInViewport,
  getBrowserName,
  searchSelectedWith,
  getClickableElements,
  tabOpenLink,
  readText,
  Clipboard,
  Front,
  Hints,
  Visual,
  RUNTIME,
  Normal,
} = api;

// === Settings ===
// settings.showModeStatus = false
// settings.showProxyInStatusBar = false
// settings.richHintsForKeystroke = 500
// settings.useLocalMarkdownAPI = true
// settings.focusOnSaved = true
// settings.omnibarMaxResults = 10
// settings.omnibarHistoryCacheSize = 100
// settings.omnibarPosition = "middle"; // ["middle", "bottom"]
// settings.omnibarSuggestion = false
// settings.omnibarSuggestionTimeout = 200
// settings.focusFirstCandidate = false
settings.tabsThreshold = 0;
// settings.verticalTabs = true
// settings.clickableSelector = ""
// settings.clickablePat = "/(https?|thunder|magnet)://\S+/ig"
// settings.editableSelector = "div.CodeMirror-scroll,div.ace_content"
settings.smoothScroll = false;
// settings.modeAfterYank = ""; // ["", "Caret", "Normal"]
settings.scrollStepSize = 140;
// settings.scrollFriction = 0;
settings.nextLinkRegex =
  "/下一章|下一页|下页|后页|下頁|後頁|下一|后一|(\b(next)\b)|more|newer|>|›|→|»|≫|>>/i";
settings.prevLinkRegex =
  "/上一章|上一页|上页|前页|上頁|前頁|上一|前一|(\b(prev|previous)\b)|back|older|<|‹|←|«|≪|<</i";
settings.hintAlign = "left"; // ["left", "center", "right"]
settings.hintExplicit = true;
settings.hintShiftNonActive = true;
// settings.defaultSearchEngine = "g"; // "g": google, "d": duckduckgo
// settings.blocklistPattern = undefined;
settings.focusAfterClosed = "last"; // ["left", "right", "last"]
// settings.repeatThreshold = 99;
// settings.tabsMRUOrder = true;
// settings.historyMUOrder = true;
// settings.newTabPosition = "default"; // ["left", "right", "first", "last", "default"]
// settings.interceptedErrors = [];
// settings.enableEmojiInsertion = false;
// settings.startToShowEmoji = 2;
// settings.language = undefined;
// settings.stealFocusOnLoad = true;
// settings.enableAutoFocus = true;
// settings.caseSensitive = false;
// settings.smartCase = true;
// settings.cursorAtEndOfInput = true;
// settings.digitForRepeat = true;
// settings.editableBodyCare = true;
// settings.ignoredFrameHosts = ["https://tpc.googlesyndication.com"];
// settings.aceKeybindings = "vim";
// settings.caretViewport = null;
// settings.mouseSelectToQuery = [];
// settings.autoSpeakOnInlineQuery = false;
// settings.showTabIndices = false;
// settings.tabIndicesSeparator = "|";
// settings.disabledOnActiveElementPatterna = undefined;

// === Extras ===
Hints.setCharacters("sadfegruijk"); // left hand only (qwerty and dvorak)

// === VISUAL MODE ===
// vmapkey("il", "0v$");
// vmapkey("is", "f.vF.");

// === MISC ===
/**
 * Map array of sources to target keymap.
 *
 * @param {string[]} sources - array of source keys
 * @param {string} target - target key
 * @returns void
 */
function multimap(sources, target) {
  sources.forEach((source) => {
    map(source, target);
  });
}

// === Keymaps ===
// toggle Surfingkeys on current site
map(";t", "<Alt-s>");
unmap("<Alt-s>");

// insert/passthrough mode
map("i", "<Alt-i>");
unmap("<Alt-i>");

// ephemeral passthrough mode 1 second
map("q", "p");
unmap("p");

// show last action
map(";la", ";ql");
unmap(";ql");

// === Link ===
// open multiple links in new inactive tabs
mapkey("F", "Open multiple links in new inactive tabs", function () {
  Hints.create("", Hints.dispatchMouseClick, {
    multipleHits: true,
    active: false,
  });
});
unmap("Ctrl-h");

map("gi", "<Ctrl-i>");
unmap("Ctrl-i");

unmap("Ctrl-j");
map("F", "C");
unmap("C");

// === History ===
multimap(["a", "h"], "S");
multimap(["s", "l"], "D");

multimap(["ga", "gh"], "[[");
multimap(["gs", "gl"], "]]");

map("_TEMP", "T");
map("T", "t");
map("t", "_TEMP");
unmap("_TEMP");

map("w", "<Ctrl-6>");

// copy link to clipboard
map("yf", "ya");
map("yF", "yf");

// === TABS ===
// go to left/right tab
map("<Alt-j>", "R");
map("<Alt-k", "E");

// move tab left/right
// map("<", "<<");
// map(">", ">>");

// === Regional Hint Mode ===

// === Insert Mode ===
// iunmap(":"); // disable emoji
iunmap("<Ctrl-i>");
iunmap("<Ctrl-a>");
iunmap("<Ctrl-e>");
iunmap("<Ctrl-u>");
iunmap("<Alt-b>");
iunmap("<Alt-f>");
iunmap("<Alt-w>");
iunmap("<Alt-d>");

// === THEME ===
const gruvbox = {
  bg0_h: "#1d2021",
  bg0_s: "#32302f",
  bg0: "#282828",
  bg1: "#3c3836",
  bg2: "#504945",
  bg3: "#665c54",
  bg4: "#7c6f64",
  fg0_h: "#f9f5d7",
  fg0: "#fbf1c7",
  fg1: "#ebdbb2",
  fg2: "#d5c4a1",
  fg3: "#bdae93",
  red: "#cc241d",
  bright_red: "#fb4934",
  green: "#98971a",
  bright_green: "#b8bb26",
  yellow: "#d79921",
  bright_yellow: "#fabd2f",
  blue: "#458588",
  bright_blue: "#83a598",
  purple: "#b16286",
  bright_purple: "#d3869b",
  aqua: "#689d6a",
  bright_aqua: "#8ec07c",
  gray: "#928374",
  bright_gray: "#a89984",
  orange: "#d65d0e",
  bright_orange: "#fe8019",
};

settings.theme = `
.sk_theme {
  # font-family: Helvetica, Arial, sans-serif;
  font-size: 20px;
  background: ${gruvbox.bg0_h};
  color: ${gruvbox.fg0};

  tbody {
    color: ${gruvbox.fg0};
  }

  input {
    color: ${gruvbox.fg0};
  }
}

#sk_usage.sk_theme {
  .feature_name > span {
    color: ${gruvbox.bright_red};
    border-bottom: 2px solid ${gruvbox.bright_red};
    font-size: 20px;
  }

  span.annotation {
    color: ${gruvbox.bright_green};
    font-size: 16px;
  }

  .kbd-span {
    min-width: 80px;
    width: auto;
  }

  kbd {
    color: ${gruvbox.bg0_h};
    background-color: ${gruvbox.fg0_h};
    font-size: 16px;
  }
}

#sk_omnibar.sk_theme {
  input {
    color: ${gruvbox.fg0};
  }
  .prompt {
    color: ${gruvbox.fg3};
  }
  .separator {
    color: ${gruvbox.bright_orange};
  }
  .resultPage {
    color: ${gruvbox.fg3};
  }
  #sk_omnibarSearchArea {
    border-bottom: 1px solid ${gruvbox.fg0};

  }

  .url {
    color: ${gruvbox.bright_blue};
  }
  .omnibar_highlight {
    color: ${gruvbox.bright_orange};
  }
  .omnibar_timestamp {
    color: ${gruvbox.fg1};
  }
  .omnibar_visitcount {
    color: ${gruvbox.bright_purple};
  }
  .omnibar_folder {
    color: ${gruvbox.bright_aqua};
  }
  .annotation {
    color: ${gruvbox.bright_green}
  }
  #sk_omnibarSearchResult {
    #max-height: none;

    ul li {
      &:nth-child(odd) {
        background: ${gruvbox.bg0_h};
      }
      &:nth-child(even) {
        background: ${gruvbox.bg0};
      }
      &.focused {
        background: ${gruvbox.bg3};
      }
    }
  }

  #sk_status, #sk_find {
    font-size: 20px;
  }
  #sk_status > span {
    line-height: 20px;
  }
}`;

// === INLINE QUERY ===
// Front.registerInlineQuery({
//   url: function (q) {
//     return `http://dict.youdao.com/w/eng/${q}/#keyfrom=dict2.index`;
//   },
//   parseResult: function (res) {
//     var parser = new DOMParser();
//     var doc = parser.parseFromString(res.text, "text/html");
//     var collinsResult = doc.querySelector("#collinsResult");
//     var authTransToggle = doc.querySelector("#authTransToggle");
//     var examplesToggle = doc.querySelector("#examplesToggle");
//     if (collinsResult) {
//       collinsResult
//         .querySelectorAll("div>span.collinsOrder")
//         .forEach(function (span) {
//           span.nextElementSibling.prepend(span);
//         });
//       collinsResult.querySelectorAll("div.examples").forEach(function (div) {
//         div.innerHTML = div.innerHTML
//           .replace(/<p/gi, "<span")
//           .replace(/<\/p>/gi, "</span>");
//       });
//       var exp = collinsResult.innerHTML;
//       return exp;
//     } else if (authTransToggle) {
//       authTransToggle.querySelector("div.via.ar").remove();
//       return authTransToggle.innerHTML;
//     } else if (examplesToggle) {
//       return examplesToggle.innerHTML;
//     }
//   },
// });

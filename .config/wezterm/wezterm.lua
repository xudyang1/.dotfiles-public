local wezterm = require("wezterm")

local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.default_prog = { "/usr/bin/bash", "-l" }
config.launch_menu = { { label = "Bash", args = { "/usr/bin/bash", "-l" } } }

config.font = wezterm.font({
  family = "FiraCode Nerd Font",
  harfbuzz_features = { "calt", "ss01", "ss03", "ss05", "cv02" },
})
config.font_size = 16.0

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.use_fancy_tab_bar = false
-- config.hide_tab_bar_if_only_one_tab = true
wezterm.on("gui-startup", function(cmd)
  local _, _, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():maximize()
  -- window:gui_window():toggle_fullscreen()
end)
config.window_background_opacity = 0.7
config.text_background_opacity = 0.7

config.color_scheme = "My Dark+"
local theme = wezterm.color.get_builtin_schemes()["Dark+"]
theme.cursor_bg = "#fbf1c7"
theme.cursor_border = "#fbf1c7"
theme.background = "#1d2021" -- Dark+: "#1e1e1e"
config.color_schemes = {
  ["My Dark+"] = theme,
}

config.enable_csi_u_key_encoding = true

local ac = wezterm.action
config.keys = {
  { key = "-", mods = "CTRL", action = ac.ScrollByLine(-10) },
  { key = "=", mods = "CTRL", action = ac.ScrollByLine(10) },
  { key = "-", mods = "CTRL|SHIFT", action = ac.DecreaseFontSize },
  { key = "=", mods = "CTRL|SHIFT", action = ac.IncreaseFontSize },
}

local is_windows = wezterm.target_triple:find("windows") ~= nil
if is_windows then
  local git_bash = wezterm.home_dir .. "/scoop/apps/git/current/bin/bash.exe"
  local nt = ac.SpawnCommandInNewTab
  local shells = {
    pwsh = { "pwsh.exe", "-NoLogo" },
    git_bash = { git_bash, "--login", "-i" },
    wsl = { "wsl.exe", "--cd", "~" },
  }

  config.default_prog = shells.pwsh
  config.launch_menu = {
    { label = "PowerShell", args = shells.pwsh },
    { label = "Git Bash", args = shells.git_bash },
    { label = "WSL", args = shells.wsl },
  }

  local keys = {
    { key = "1", mods = "CTRL|ALT", action = nt({ args = shells.pwsh }) },
    { key = "2", mods = "CTRL|ALT", action = nt({ args = shells.git_bash }) },
    { key = "3", mods = "CTRL|ALT", action = nt({ args = shells.wsl }) },
  }

  for _, v in ipairs(keys) do
    table.insert(config.keys, v)
  end
end

return config

local wezterm = require("wezterm")
local config = {}

-- Colors and appearance
config.colors = {
  foreground = "#ebdbb2",
  background = "#32302f", -- This is the brown-ish Gruvbox background
  cursor_bg = "#ebdbb2",
  cursor_fg = "#32302f",
  cursor_border = "#ebdbb2",

  -- Normal colors
  ansi = {
    "#32302f", -- black (changed to match background)
    "#cc241d", -- red
    "#98971a", -- green
    "#d79921", -- yellow
    "#458588", -- blue
    "#b16286", -- magenta
    "#689d6a", -- cyan
    "#a89984", -- white
  },

  -- Bright colors
  brights = {
    "#928374", -- bright black
    "#fb4934", -- bright red
    "#b8bb26", -- bright green
    "#fabd2f", -- bright yellow
    "#83a598", -- bright blue
    "#d3869b", -- bright magenta
    "#8ec07c", -- bright cyan
    "#ebdbb2", -- bright white
  },
}

-- Colors and appearance
config.color_scheme = "Gruvbox Dark"

-- Font configuration
config.font = wezterm.font_with_fallback({
  "RecMonoDuotone Nerd Font",
})

config.font_size = 12

-- Window padding
local padding = 0;
config.window_padding = {
  left = padding,
  right = padding,
  top = padding,
  bottom = padding,
}

-- Tab bar styling
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true

-- If you want darker background for better readability with transparency
config.window_frame = {
  active_titlebar_bg = "#282828",
  inactive_titlebar_bg = "#1d2021",
}

return config

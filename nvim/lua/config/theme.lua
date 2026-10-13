-- Which colorscheme this Neovim should wear.
--
-- The OS appearance is the source of truth for light/dark (see sh/theme.sh),
-- and a *profile* picks which pair of themes light/dark mean:
--
--   catppuccin     light -> latte                 dark -> mocha
--   scleral        light -> no clown fiesta light dark -> kanagawa dragon
--   kanso-scleral  light -> kanso pearl           dark -> kanagawa dragon
--
-- The two scleral profiles are chosen for the lowest visible light scatter;
-- their halves come from different families because each is picked on its own
-- merits. They differ only in the light half, which is the one that scatters.
-- Both are read from the cache `make light` / `make dark` write, so Neovim
-- never has to shell out.
local M = {}

local function cache_dir()
  return (vim.env.XDG_CACHE_HOME or (vim.env.HOME .. "/.cache")) .. "/dev-setup/"
end

local function read(name, allowed, fallback)
  local f = io.open(cache_dir() .. name, "r")
  if f then
    local v = (f:read("l") or ""):gsub("%s", "")
    f:close()
    if allowed[v] then return v end
  end
  return fallback
end

function M.mode()
  local m = read("flavour", { light = true, dark = true }, nil)
  if m then return m end
  return vim.env.DEV_SETUP_THEME == "light" and "light" or "dark"
end

-- The profiles this Neovim knows, and what each resolves to. SCHEMES is the
-- `:colorscheme` name, which is *not* the slug -- `kanagawa-dragon` is the slug
-- but `kanagawa` is the colourscheme. SLUGS is the slug every per-theme file is
-- named after; it has to match THEME_PROFILES in sh/lib.sh and
-- DEV_SETUP_PROFILE_SLUGS in zsh/theme.zsh (THEMES.md).
local SCHEMES = {
  catppuccin      = { light = "catppuccin",       dark = "catppuccin" },
  scleral         = { light = "no-clown-fiesta",  dark = "kanagawa-dragon" },
  ["kanso-scleral"] = { light = "kanso-pearl",    dark = "kanagawa-dragon" },
}

local SLUGS = {
  catppuccin      = { light = "latte",       dark = "mocha" },
  scleral         = { light = "ncf-light",   dark = "kanagawa-dragon" },
  ["kanso-scleral"] = { light = "kanso-pearl", dark = "kanagawa-dragon" },
}

-- Validated against SLUGS rather than a second list, so adding a profile above
-- is the only edit; an unknown name falls back to Catppuccin.
function M.profile()
  local allowed = {}
  for name in pairs(SLUGS) do allowed[name] = true end
  return read("profile", allowed, "catppuccin")
end

function M.slug()
  return (SLUGS[M.profile()] or SLUGS.catppuccin)[M.mode()]
end

-- The 26 Catppuccin colour names for whichever theme is active, so the bars
-- (lualine, bufferline) can be coloured the same way under every profile.
--
-- Catppuccin publishes its own palettes; everything else is generated into
-- nvim/lua/themes/<slug>.lua by sh/gen-theme.py, with the same keys.
--
-- Not keyed off vim.o.background: a colourscheme is free to leave that wrong,
-- and the scleral profile's light half does (no-clown-fiesta's light variant
-- applies light colours with 'background' still on "dark"). Anything reading
-- the flag then picks its dark defaults over a light page -- lualine's "auto"
-- theme above all. The cache is the source of truth here, as everywhere else.
function M.palette()
  local slug = M.slug()
  if slug == "latte" or slug == "mocha" then
    local ok, p = pcall(function() return require("catppuccin.palettes").get_palette(slug) end)
    if ok and p then return p end
  end
  local ok, p = pcall(require, "themes." .. slug)
  if ok and type(p) == "table" then return p end
  return require("catppuccin.palettes").get_palette("mocha")
end

-- A lualine theme in Catppuccin's shape, from any palette. Used for the
-- profiles that have no lualine port of their own; the Catppuccin profile
-- keeps the official one ("auto" finds it).
function M.lualine_theme()
  local c = M.palette()
  local function mode_colors(accent)
    return { a = { bg = accent, fg = c.base, gui = "bold" }, b = { bg = c.surface0, fg = accent } }
  end
  local t = {
    normal   = mode_colors(c.blue),
    insert   = mode_colors(c.green),
    terminal = mode_colors(c.teal),
    command  = mode_colors(c.peach),
    visual   = mode_colors(c.mauve),
    replace  = mode_colors(c.red),
    inactive = {
      a = { bg = c.mantle, fg = c.blue },
      b = { bg = c.mantle, fg = c.surface1, gui = "bold" },
      c = { bg = c.mantle, fg = c.overlay0 },
    },
  }
  -- The middle section is the bar's own background: the same mantle the tmux
  -- bar uses, so the two read as one surface. Without it lualine leaves the
  -- gaps between sections on the colourscheme's StatusLine group, which is
  -- where the light "gap" in a dark bar came from.
  for _, name in ipairs({ "normal", "insert", "terminal", "command", "visual", "replace" }) do
    t[name].c = { bg = c.mantle, fg = c.text }
  end
  return t
end

-- Bufferline highlights, in the same spirit as catppuccin's bufferline port:
-- the open buffer on the editor's own background, the rest sunk into the
-- mantle the bar is drawn on. Catppuccin keeps its port (M.bufferline below);
-- this is for the profiles that have none, which would otherwise be left with
-- whatever bufferline derives -- for a colourscheme that lies about
-- 'background', a near-black tab bar over a light page.
function M.bufferline_highlights()
  local c = M.palette()
  local hl, on_bar, on_page = {}, { bg = c.mantle }, { bg = c.base }
  local function set(group, fg, bg, extra)
    hl[group] = vim.tbl_extend("force", { fg = fg, bg = bg }, extra or {})
  end
  set("fill", c.overlay0, c.mantle)
  set("background", c.overlay1, c.mantle)
  set("buffer_visible", c.subtext0, c.base)
  set("buffer_selected", c.text, c.base, { bold = true, italic = false })
  set("separator", c.mantle, c.mantle)
  set("separator_visible", c.mantle, c.base)
  set("separator_selected", c.mantle, c.base)
  set("indicator_visible", c.base, c.base)
  set("indicator_selected", c.blue, c.base)
  set("duplicate", c.overlay0, c.mantle, { italic = true })
  set("duplicate_visible", c.subtext0, c.base, { italic = true })
  set("duplicate_selected", c.text, c.base, { italic = true })
  set("tab", c.overlay1, c.mantle)
  set("tab_selected", c.blue, c.base, { bold = true })
  set("tab_separator", c.mantle, c.mantle)
  set("tab_separator_selected", c.mantle, c.base)
  set("offset_separator", c.mantle, c.mantle)
  -- One colour per state, on the bar or on the page depending on the tab.
  for _, s in ipairs({
    { "modified", c.peach }, { "close_button", c.overlay1 },
    { "error", c.red }, { "warning", c.yellow }, { "info", c.sky }, { "hint", c.teal },
    { "error_diagnostic", c.red }, { "warning_diagnostic", c.yellow },
    { "info_diagnostic", c.sky }, { "hint_diagnostic", c.teal },
  }) do
    local name, colour = s[1], s[2]
    hl[name] = vim.tbl_extend("force", { fg = colour }, on_bar)
    hl[name .. "_visible"] = vim.tbl_extend("force", { fg = colour }, on_page)
    hl[name .. "_selected"] = vim.tbl_extend("force", { fg = colour, bold = true }, on_page)
  end
  hl.close_button_selected = { fg = c.red, bg = c.base }
  return hl
end

-- Bufferline's colours for the active profile: Catppuccin's own port where it
-- applies, the table above otherwise.
function M.bufferline()
  if M.profile() == "catppuccin" then
    local ok, t = pcall(function() return require("catppuccin.special.bufferline").get_theme() end)
    if ok and t then return t end
  end
  return M.bufferline_highlights()
end

function M.apply()
  local mode, profile = M.mode(), M.profile()
  -- Set it first, for the colorschemes that pick their variant from it...
  vim.o.background = mode
  local scheme = (SCHEMES[profile] or SCHEMES.catppuccin)[mode]
  -- A missing colorscheme must not break startup: fall back to catppuccin,
  -- which is always installed.
  local ok = pcall(vim.cmd.colorscheme, scheme)
  if not ok then pcall(vim.cmd.colorscheme, "catppuccin") end
  -- Set before the colorscheme and deliberately not re-asserted after: setting
  -- 'background' once a colorscheme is loaded makes Neovim reset every
  -- highlight group to its built-in default, throwing the theme away. So a
  -- theme that ignores the flag (no-clown-fiesta's light variant, the scleral
  -- profile's light half, leaves it on "dark" while painting light) cannot be
  -- corrected -- which is why nothing here is allowed to trust it. Kanso Pearl
  -- reads it properly; no-clown-fiesta does not, and the next theme might not.
  --
  -- The two bars are drawn on the mantle (M.lualine_theme, M.bufferline), but
  -- the cells neither plugin paints -- the stretch between lualine's middle
  -- and right sections above all -- fall back to these groups. Left on the
  -- colourscheme's own they were a paler shade than the bar, which is the gap
  -- that appeared and disappeared with the length of the middle section.
  local c = M.palette()
  vim.api.nvim_set_hl(0, "StatusLine", { fg = c.text, bg = c.mantle })
  vim.api.nvim_set_hl(0, "StatusLineNC", { fg = c.overlay1, bg = c.mantle })
  vim.api.nvim_set_hl(0, "TabLineFill", { fg = c.overlay0, bg = c.mantle })
  M._applied = profile .. "/" .. mode
end

-- Re-apply only on a real change; recompiling a colorscheme on every focus
-- event is wasted work.
function M.sync()
  if M._applied ~= (M.profile() .. "/" .. M.mode()) then M.apply() end
end

return M

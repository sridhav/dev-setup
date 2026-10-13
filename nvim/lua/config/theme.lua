-- Which colorscheme this Neovim should wear.
--
-- The OS appearance is the source of truth for light/dark (see sh/theme.sh),
-- and a *profile* picks which pair of themes light/dark mean:
--
--   catppuccin  light -> latte           dark -> mocha
--   scleral     light -> no-clown-fiesta dark -> kanagawa dragon
--
-- The scleral pair is chosen for the lowest visible light scatter, which is why
-- its dark half is a different family: No Clown Fiesta's own dark is harsh.
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

function M.profile()
  return read("profile", { catppuccin = true, scleral = true }, "catppuccin")
end

-- profile+mode -> the colorscheme command to run
local SCHEMES = {
  catppuccin = { light = "catppuccin", dark = "catppuccin" },
  scleral    = { light = "no-clown-fiesta", dark = "kanagawa-dragon" },
}

function M.apply()
  local mode, profile = M.mode(), M.profile()
  -- Set it first, for the colorschemes that pick their variant from it...
  vim.o.background = mode
  local scheme = (SCHEMES[profile] or SCHEMES.catppuccin)[mode]
  -- A missing colorscheme must not break startup: fall back to catppuccin,
  -- which is always installed.
  local ok = pcall(vim.cmd.colorscheme, scheme)
  if not ok then pcall(vim.cmd.colorscheme, "catppuccin") end
  -- Deliberately NOT re-asserted afterwards. no-clown-fiesta's light variant
  -- (upstream calls it "under development") leaves 'background' on "dark" even
  -- though it applies light colours -- but setting 'background' after a
  -- colorscheme makes Neovim reset every highlight group to its built-in
  -- default, which throws the theme away entirely. Wrong flag, right colours
  -- beats right flag, no theme.
  M._applied = profile .. "/" .. mode
end

-- Re-apply only on a real change; recompiling a colorscheme on every focus
-- event is wasted work.
function M.sync()
  if M._applied ~= (M.profile() .. "/" .. M.mode()) then M.apply() end
end

return M

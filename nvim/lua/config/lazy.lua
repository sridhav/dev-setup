local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
  -- Start lazy.nvim at the commit pinned in lazy-lock.json, not the latest
  -- release, so a fresh machine matches the others and the lockfile stays
  -- unchanged. (lazy.nvim records the version it's running as, and doesn't
  -- move itself during :Lazy restore.)
  local lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json"
  local ok, lock = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(lockfile), "\n"))
  end)
  if ok and lock["lazy.nvim"] then
    vim.fn.system({ "git", "-C", lazypath, "checkout", "--quiet", lock["lazy.nvim"].commit })
  end
end
vim.opt.rtp:prepend(lazypath)

-- vim-options.lua sets mapleader; it must run before lazy.setup()
require("vim-options")
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  install = { colorscheme = { "habamax" } },
  checker = { enabled = true, notify = false },
  -- No plugin here needs luarocks; without this, :checkhealth reports an error.
  rocks = { enabled = false },
})

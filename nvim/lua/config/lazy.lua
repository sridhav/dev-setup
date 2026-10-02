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
end

-- Keep lazy.nvim itself at the commit pinned in lazy-lock.json, on every start.
-- lazy.nvim writes the version it's running as into the lockfile, and
-- `:Lazy restore` doesn't move it, so a machine with an older or newer copy
-- rewrites the lockfile and leaves the repo dirty (make update then refuses).
-- Reading .git/HEAD is cheap; git only runs when it's on the wrong commit.
do
  local ok, lock = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(vim.fn.stdpath("config") .. "/lazy-lock.json"), "\n"))
  end)
  local want = ok and lock["lazy.nvim"] and lock["lazy.nvim"].commit
  local head = vim.fn.readfile(lazypath .. "/.git/HEAD")[1]
  if want and head ~= want then
    local function checkout()
      vim.fn.system({ "git", "-C", lazypath, "checkout", "--quiet", want })
      return vim.v.shell_error == 0
    end
    if not checkout() then
      vim.fn.system({ "git", "-C", lazypath, "fetch", "--quiet", "origin" })
      checkout()
    end
  end
end
vim.opt.rtp:prepend(lazypath)

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

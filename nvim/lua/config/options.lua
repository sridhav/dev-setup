-- Leader must be set before any plugin defines a <leader> mapping.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- No remote plugins use the Python/Ruby/Perl/Node hosts. Disabling them skips
-- their startup probing and the :checkhealth warnings about missing modules.
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

local opt = vim.opt

-- Indentation
opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.shiftround = true -- > and < snap to a multiple of shiftwidth
opt.smartindent = true

-- UI
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes" -- stop the text jumping when diagnostics appear
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.linebreak = true -- when wrap is on (markdown, commits), break at words
opt.smoothscroll = true -- scroll wrapped lines by screen line, not whole line
opt.termguicolors = true
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen" -- text stays put when Trouble or a terminal opens below
opt.showmode = false -- lualine already shows the mode
opt.pumheight = 10 -- completion menu height
opt.virtualedit = "block" -- Ctrl-v can select past the end of short lines
opt.fillchars = { eob = " ", fold = " " } -- no ~ past the end, no dots after folds

-- Folding by syntax. foldlevel 99 opens every fold on load; za / zc / zR fold.
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = "" -- show the first line of the fold with its highlighting
opt.foldlevel = 99

-- Search
opt.ignorecase = true
opt.smartcase = true -- case-sensitive only when the pattern has a capital
opt.inccommand = "split" -- live preview of :%s///
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"

-- Files / history
opt.undofile = true -- persistent undo across restarts
opt.undolevels = 10000
opt.swapfile = false
opt.updatetime = 250
opt.timeoutlen = 400 -- how long which-key waits
opt.confirm = true -- prompt instead of failing on :q with unsaved changes
opt.jumpoptions = "view" -- Ctrl-o / Ctrl-i restore the scroll position too

-- Use the system clipboard, but not until the UI is up: querying the
-- clipboard provider at startup costs ~50ms.
vim.schedule(function()
	opt.clipboard = "unnamedplus"
end)

-- Diagnostics: Neovim 0.11+ ships with virtual_text OFF, so linter/LSP
-- messages were invisible unless you hovered or opened the loclist.
vim.diagnostic.config({
	virtual_text = { spacing = 2, prefix = "●" },
	severity_sort = true,
	float = { border = "rounded", source = true },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚 ",
			[vim.diagnostic.severity.WARN] = "󰀪 ",
			[vim.diagnostic.severity.INFO] = "󰋽 ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
		},
	},
})

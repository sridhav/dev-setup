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
opt.smartindent = true

-- UI
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes" -- stop the text jumping when diagnostics appear
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.termguicolors = true
opt.splitright = true
opt.splitbelow = true

-- Search
opt.ignorecase = true
opt.smartcase = true -- case-sensitive only when the pattern has a capital
opt.inccommand = "split" -- live preview of :%s///

-- Files / history
opt.undofile = true -- persistent undo across restarts
opt.swapfile = false
opt.updatetime = 250
opt.timeoutlen = 400 -- how long which-key waits
opt.confirm = true -- prompt instead of failing on :q with unsaved changes

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

local map = vim.keymap.set
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Open CHEATSHEET.md (in this config) in a read-only floating window.
map("n", "<leader>k", function()
	local path = vim.fn.stdpath("config") .. "/CHEATSHEET.md"
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.fn.readfile(path))
	vim.bo[buf].filetype = "markdown"
	vim.bo[buf].modifiable = false
	local width = math.min(90, vim.o.columns - 4)
	local height = math.min(vim.api.nvim_buf_line_count(buf), vim.o.lines - 6)
	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2) - 1,
		col = math.floor((vim.o.columns - width) / 2),
		border = "rounded",
		title = " Cheat sheet ",
		title_pos = "center",
	})
	for _, key in ipairs({ "q", "<Esc>" }) do
		vim.keymap.set("n", key, "<cmd>close<cr>", { buffer = buf, nowait = true })
	end
end, { desc = "Keymap cheat sheet" })
-- <C-h/j/k/l> window navigation lives in plugins/tmux-navigator.lua

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight on yank",
	group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Pick up files changed on disk by something else (Claude, opencode, git).
-- 'autoread' is on by default, but it only acts when Neovim actually stats the
-- file; a buffer sitting on screen never does. These events make it check.
-- tmux's `focus-events on` is what lets FocusGained fire inside a pane.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermClose", "TermLeave" }, {
	desc = "Reload buffers changed on disk",
	group = vim.api.nvim_create_augroup("checktime_on_change", { clear = true }),
	callback = function()
		-- checktime is invalid while the command line or cmdwin is open.
		if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
			vim.cmd("checktime")
		end
	end,
})

-- Say so when a buffer was swapped out from under the cursor.
vim.api.nvim_create_autocmd("FileChangedShellPost", {
	desc = "Notify when a buffer was reloaded from disk",
	group = vim.api.nvim_create_augroup("checktime_notify", { clear = true }),
	callback = function()
		vim.notify("File changed on disk, buffer reloaded", vim.log.levels.WARN)
	end,
})

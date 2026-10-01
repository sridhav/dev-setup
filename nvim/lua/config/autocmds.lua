local function augroup(name)
	return vim.api.nvim_create_augroup(name, { clear = true })
end

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight on yank",
	group = augroup("highlight_yank"),
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
	group = augroup("checktime_on_change"),
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
	group = augroup("checktime_notify"),
	callback = function()
		vim.notify("File changed on disk, buffer reloaded", vim.log.levels.WARN)
	end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
	desc = "Reopen a file where the cursor was last time",
	group = augroup("last_loc"),
	callback = function(ev)
		-- A commit message always starts fresh at the top.
		if vim.bo[ev.buf].filetype == "gitcommit" or vim.b[ev.buf].last_loc_done then
			return
		end
		vim.b[ev.buf].last_loc_done = true
		local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
		if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	desc = "Close helper windows with q",
	group = augroup("close_with_q"),
	pattern = {
		"checkhealth",
		"dap-float",
		"gitsigns-blame",
		"grug-far",
		"help",
		"lspinfo",
		"man",
		"notify",
		"qf",
		"startuptime",
	},
	callback = function(ev)
		vim.bo[ev.buf].buflisted = false
		vim.schedule(function()
			vim.keymap.set("n", "q", function()
				vim.cmd("close")
				pcall(vim.api.nvim_buf_delete, ev.buf, { force = true })
			end, { buffer = ev.buf, silent = true, desc = "Close window" })
		end)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	desc = "Wrap and spell check prose",
	group = augroup("wrap_spell"),
	pattern = { "text", "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	desc = "Create missing parent directories on save",
	group = augroup("auto_create_dir"),
	callback = function(ev)
		-- Skip URLs (scp://, oil://, …): there is no local directory to make.
		if ev.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(ev.match) or ev.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

vim.api.nvim_create_autocmd("VimResized", {
	desc = "Equalize splits when the terminal is resized",
	group = augroup("resize_splits"),
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
})

-- Keymaps that belong to no plugin. Plugin keys live in that plugin's spec.
local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
-- <C-h/j/k/l> window navigation lives in plugins/tmux-navigator.lua

-- j/k move by screen line through wrapped text, unless given a count (5j).
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Down" })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Up" })

-- Move the line (or selection) up and down. On macOS, Ghostty sends the left
-- Option key as Alt (macos-option-as-alt in ghostty/macos.conf).
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move line up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
map("x", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move selection down" })
map("x", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move selection up" })

-- Keep the selection after indenting so > can be pressed again.
map("x", "<", "<gv", { desc = "Unindent" })
map("x", ">", ">gv", { desc = "Indent" })

-- Undo checkpoints: u undoes back to the last , . or ; instead of the whole insert.
for _, char in ipairs({ ",", ".", ";" }) do
	map("i", char, char .. "<c-g>u")
end

-- Add a comment line below / above, in the buffer's comment syntax.
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add comment below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add comment above" })

-- Diagnostics. ]d / [d (every severity) are Neovim defaults.
local function jump_to(severity, count)
	return function()
		vim.diagnostic.jump({ count = count, severity = vim.diagnostic.severity[severity], float = true })
	end
end
map("n", "]e", jump_to("ERROR", 1), { desc = "Next error" })
map("n", "[e", jump_to("ERROR", -1), { desc = "Previous error" })
map("n", "]w", jump_to("WARN", 1), { desc = "Next warning" })
map("n", "[w", jump_to("WARN", -1), { desc = "Previous warning" })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- Windows and buffers
map("n", "<leader>-", "<C-w>s", { desc = "Split below" })
map("n", "<leader>|", "<C-w>v", { desc = "Split right" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Previous buffer" })
map("n", "<leader>Q", "<cmd>qa<cr>", { desc = "Quit all" })
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy (plugins)" })

-- Open CHEATSHEET.md (in this config) in a read-only floating window.
map("n", "<leader>k", function()
	local path = vim.fn.stdpath("config") .. "/CHEATSHEET.md"
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.fn.readfile(path))
	vim.bo[buf].filetype = "markdown"
	vim.bo[buf].modifiable = false
	local width = math.min(90, vim.o.columns - 4)
	local height = math.min(vim.api.nvim_buf_line_count(buf), vim.o.lines - 6)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2) - 1,
		col = math.floor((vim.o.columns - width) / 2),
		border = "rounded",
		title = " Cheat sheet ",
		title_pos = "center",
	})
	-- The markdown autocmd turns spell on; key names aren't words.
	vim.wo[win].spell = false
	for _, key in ipairs({ "q", "<Esc>" }) do
		vim.keymap.set("n", key, "<cmd>close<cr>", { buffer = buf, nowait = true })
	end
end, { desc = "Keymap cheat sheet" })

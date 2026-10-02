-- folke's collection of small UI pieces. Only the parts below are enabled; the
-- rest of snacks stays off. The picker replaced Telescope: same keys, faster,
-- and it searches from the project root (config/root.lua), not the cwd.
local root = function()
	return require("config.root").get()
end

return {
	"folke/snacks.nvim",
	-- Loaded at startup: the dashboard, notifier and bigfile must be in place
	-- before the first buffer opens.
	priority = 1000,
	lazy = false,
	opts = {
		bigfile = { enabled = true }, -- files over 1.5 MB skip treesitter/LSP so they open instantly
		indent = { enabled = true }, -- indent guides; the current scope is highlighted
		input = { enabled = true }, -- vim.ui.input as a float (LSP rename, …)
		notifier = { enabled = true }, -- vim.notify pop-ups, with history
		words = { enabled = true }, -- highlight the word under the cursor across the buffer
		-- File tree sidebar. Also opens for `nvim .` instead of netrw.
		explorer = { enabled = true },
		-- Uses your lazygit/config.yml as is: `configure` would recolor it from
		-- the Neovim theme and drop its blue accent.
		lazygit = { configure = false },
		picker = {
			enabled = true, -- also takes over vim.ui.select
			sources = {
				-- Dotfiles are shown (this repo is mostly dotfiles); .git never is.
				files = { hidden = true },
				grep = { hidden = true },
				-- Show dotfiles and gitignored files in the tree too (H / I toggle them).
				explorer = { hidden = true, ignored = true },
			},
		},
		dashboard = {
			enabled = true,
			preset = {
				keys = {
					{ icon = "\u{f002} ", key = "f", desc = "Find file", action = ":lua Snacks.picker.files()" },
					{ icon = "\u{f0f6} ", key = "n", desc = "New file", action = ":ene | startinsert" },
					{ icon = "\u{f0e5} ", key = "g", desc = "Grep", action = ":lua Snacks.picker.grep()" },
					{ icon = "\u{f1da} ", key = "r", desc = "Recent files", action = ":lua Snacks.picker.recent()" },
					{
						icon = "\u{f013} ",
						key = "c",
						desc = "Config",
						action = ":lua Snacks.picker.files({ cwd = vim.fn.stdpath('config') })",
					},
					-- Restores this directory's persistence.nvim session.
					{ icon = "\u{f0c7} ", key = "s", desc = "Restore session", section = "session" },
					{ icon = "\u{f1b2} ", key = "l", desc = "Lazy (plugins)", action = ":Lazy" },
					{ icon = "\u{f011} ", key = "q", desc = "Quit", action = ":qa" },
				},
			},
		},
		-- No "1: user@host:dir" bar above the terminal: the status line shows
		-- the command, directory and terminal number instead (lualine.lua).
		terminal = { win = { wo = { winbar = "" } } },
	},
	keys = {
		-- Find (same keys Telescope had)
		{
			"<C-p>",
			function()
				Snacks.picker.files({ cwd = root() })
			end,
			desc = "Find files (root)",
		},
		{
			"<leader>ff",
			function()
				Snacks.picker.files({ cwd = root() })
			end,
			desc = "Find files (root)",
		},
		{
			"<leader>fF",
			function()
				Snacks.picker.files()
			end,
			desc = "Find files (cwd)",
		},
		{
			"<leader>fg",
			function()
				Snacks.picker.grep({ cwd = root() })
			end,
			desc = "Grep (root)",
		},
		{
			"<leader>fG",
			function()
				Snacks.picker.grep()
			end,
			desc = "Grep (cwd)",
		},
		{
			"<leader>fw",
			function()
				Snacks.picker.grep_word({ cwd = root() })
			end,
			mode = { "n", "x" },
			desc = "Grep word or selection",
		},
		{
			"<leader>fb",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Buffers",
		},
		{
			"<leader>fr",
			function()
				Snacks.picker.recent()
			end,
			desc = "Recent files",
		},
		{
			"<leader>fh",
			function()
				Snacks.picker.help()
			end,
			desc = "Help tags",
		},
		{
			"<leader>fk",
			function()
				Snacks.picker.keymaps()
			end,
			desc = "Search keymaps",
		},
		{
			"<leader>fd",
			function()
				Snacks.picker.diagnostics()
			end,
			desc = "Diagnostics",
		},
		{
			"<leader>fc",
			function()
				Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
			end,
			desc = "Config files",
		},
		{
			"<leader>fu",
			function()
				Snacks.picker.undo()
			end,
			desc = "Undo history",
		},
		{
			"<leader>fR",
			function()
				Snacks.picker.resume()
			end,
			desc = "Resume last picker",
		},
		{
			"<leader>/",
			function()
				Snacks.picker.lines()
			end,
			desc = "Search in buffer",
		},

		-- File tree
		{
			"<C-n>",
			function()
				local explorer = Snacks.picker.get({ source = "explorer" })[1]
				if explorer then
					explorer:close()
				else
					Snacks.explorer()
				end
			end,
			desc = "Toggle file tree",
		},
		{
			"<leader>e",
			function()
				Snacks.explorer.reveal()
			end,
			desc = "Reveal file in tree",
		},

		-- Git
		{
			"<leader>gg",
			function()
				Snacks.lazygit()
			end,
			desc = "LazyGit",
		},
		{
			"<leader>gf",
			function()
				Snacks.lazygit({ cwd = Snacks.git.get_root() })
			end,
			desc = "LazyGit (current file's repo)",
		},
		{
			"<leader>gl",
			function()
				Snacks.lazygit.log_file()
			end,
			desc = "Commits touching current file",
		},

		-- Buffers
		{
			"<leader>bd",
			function()
				Snacks.bufdelete()
			end,
			desc = "Delete buffer",
		},
		{
			"<leader>bo",
			function()
				Snacks.bufdelete.other()
			end,
			desc = "Delete other buffers",
		},

		-- Terminal: Ctrl-/ toggles it. Inside tmux the key arrives as Ctrl-_.
		{
			"<C-/>",
			function()
				Snacks.terminal(nil, { cwd = root() })
			end,
			desc = "Terminal",
		},
		{
			"<C-_>",
			function()
				Snacks.terminal(nil, { cwd = root() })
			end,
			desc = "which_key_ignore",
		},
		{ "<C-/>", "<cmd>close<cr>", mode = "t", desc = "Hide terminal" },
		{ "<C-_>", "<cmd>close<cr>", mode = "t", desc = "which_key_ignore" },

		-- Jump between the highlighted uses of the word under the cursor.
		{
			"]]",
			function()
				Snacks.words.jump(vim.v.count1)
			end,
			desc = "Next reference",
		},
		{
			"[[",
			function()
				Snacks.words.jump(-vim.v.count1)
			end,
			desc = "Previous reference",
		},

		{
			"<leader>nn",
			function()
				Snacks.notifier.show_history()
			end,
			desc = "Notification history",
		},
		{
			"<leader>gB",
			function()
				Snacks.gitbrowse()
			end,
			mode = { "n", "x" },
			desc = "Open on GitHub",
		},
	},
	init = function()
		-- Toggles under <leader>t, next to tf (format on save) and tb (blame).
		-- Each one says on/off and shows its state in which-key.
		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy",
			once = true,
			callback = function()
				Snacks.toggle.inlay_hints():map("<leader>th")
				Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>tw")
				Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>ts")
				Snacks.toggle.diagnostics():map("<leader>td")
				Snacks.toggle.indent():map("<leader>ti")
			end,
		})
	end,
}

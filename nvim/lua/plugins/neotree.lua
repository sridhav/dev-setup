return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	-- Must not be lazy-loaded: neo-tree has to be running at startup to take
	-- over directory buffers (`nvim .`) from netrw. It defers its own work.
	lazy = false,
	keys = {
		{ "<C-n>", "<cmd>Neotree filesystem toggle left<cr>", desc = "Toggle file tree" },
		{ "<leader>e", "<cmd>Neotree filesystem reveal left<cr>", desc = "Reveal file in tree" },
	},
	opts = {
		close_if_last_window = true,
		window = { position = "left", width = 32 },
		filesystem = {
			-- Opening a directory shows neo-tree as the left sidebar instead of netrw.
			hijack_netrw_behavior = "open_default",
			follow_current_file = { enabled = true },
			use_libuv_file_watcher = true,
			filtered_items = { hide_dotfiles = false, hide_gitignored = true },
		},
	},
}

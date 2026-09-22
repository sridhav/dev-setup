return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		preset = "helix",
		spec = {
			{ "<leader>f", group = "find" },
			{ "<leader>c", group = "code" },
			{ "<leader>t", group = "toggle" },
			{ "<leader>w", group = "workspace" },
			{ "<leader>g", group = "git" },
			{ "<leader>h", group = "git hunks" },
			{ "<leader>x", group = "trouble" },
			{ "<leader>S", group = "session" },
		},
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer local keymaps (which-key)",
		},
	},
}

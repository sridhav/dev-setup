return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	lazy = false,
	opts = {
		flavour = "mocha", -- latte | frappe | macchiato | mocha
		transparent_background = false,
		integrations = {
			blink_cmp = true,
			neotree = true,
			telescope = { enabled = true },
			which_key = true,
			treesitter = true,
			native_lsp = { enabled = true, underlines = { errors = { "undercurl" } } },
			mason = true,
			render_markdown = true,
		},
	},
	config = function(_, opts)
		require("catppuccin").setup(opts)
		vim.cmd.colorscheme("catppuccin")
	end,
}

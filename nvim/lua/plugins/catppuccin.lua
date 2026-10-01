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
			snacks = { enabled = true },
			noice = true,
			grug_far = true,
			treesitter_context = true,
			lsp_trouble = true,
			dap = true,
			dap_ui = true,
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

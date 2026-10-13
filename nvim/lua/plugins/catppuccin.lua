-- Catppuccin: Latte in light mode, Mocha in dark -- the default profile.
-- Which colorscheme actually gets applied is decided in lua/config/theme.lua,
-- because the scleral profile swaps in a different pair.
--
-- `background` makes the flavour follow vim.o.background, so switching themes
-- is just setting that. The OS appearance is the source of truth for the whole
-- setup (see sh/theme.sh); this reads the flavour that `make light` / `make
-- dark` cached, falling back to $DEV_SETUP_THEME from the shell and then to
-- dark, so a fresh machine with no cache still looks right.
return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	lazy = false,
	opts = {
		background = { light = "latte", dark = "mocha" },
		transparent_background = false,
		integrations = {
			blink_cmp = true,
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
		local theme = require("config.theme")
		theme.apply()

		-- Pick up `make light` / `make dark` (and a profile change) without
		-- restarting. tmux's `focus-events on` is what lets FocusGained fire
		-- inside a pane.
		vim.api.nvim_create_autocmd({ "FocusGained", "VimResume" }, {
			group = vim.api.nvim_create_augroup("dev_setup_theme", { clear = true }),
			desc = "Follow the OS light/dark switch",
			callback = theme.sync,
		})
	end,
}

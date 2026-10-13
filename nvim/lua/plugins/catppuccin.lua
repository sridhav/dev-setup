-- Catppuccin: Latte when the OS is in light mode, Mocha when it is dark.
--
-- `background` makes the flavour follow vim.o.background, so switching themes
-- is just setting that. The OS appearance is the source of truth for the whole
-- setup (see sh/theme.sh); this reads the flavour that `make light` / `make
-- dark` cached, falling back to $DEV_SETUP_THEME from the shell and then to
-- dark, so a fresh machine with no cache still looks right.
local cache = vim.env.XDG_CACHE_HOME or (vim.env.HOME .. "/.cache")
cache = cache .. "/dev-setup/flavour"

local function detect()
	local f = io.open(cache, "r")
	if f then
		local mode = (f:read("l") or ""):gsub("%s", "")
		f:close()
		if mode == "light" or mode == "dark" then
			return mode
		end
	end
	return vim.env.DEV_SETUP_THEME == "light" and "light" or "dark"
end

-- Re-apply only on a real change: setting background always recompiles the
-- colorscheme, which is wasted work on every focus event.
local function sync()
	local mode = detect()
	if vim.o.background ~= mode then
		vim.o.background = mode
		vim.cmd.colorscheme("catppuccin")
	end
end

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
		vim.o.background = detect()
		vim.cmd.colorscheme("catppuccin")

		-- Pick up `make light` / `make dark` without restarting Neovim. tmux's
		-- `focus-events on` is what lets FocusGained fire inside a pane.
		vim.api.nvim_create_autocmd({ "FocusGained", "VimResume" }, {
			group = vim.api.nvim_create_augroup("dev_setup_theme", { clear = true }),
			desc = "Follow the OS light/dark switch",
			callback = sync,
		})
	end,
}

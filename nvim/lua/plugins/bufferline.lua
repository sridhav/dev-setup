-- Open buffers as tabs along the top. Hidden while only one buffer is open.

-- Rebuilt whenever the colourscheme changes, so the tab bar follows
-- `make light` / `make dark` and a profile switch in an open Neovim.
local function make_opts()
	return {
		-- Colours for whichever theme is active: Catppuccin's bufferline port
		-- under that profile, a palette-built set under any other
		-- (lua/config/theme.lua). Taking Catppuccin's unconditionally is what
		-- painted a Mocha-black tab bar over the light scleral theme: that
		-- theme left 'background' on "dark", so the port handed back its
		-- dark flavour.
		highlights = require("config.theme").bufferline(),
		options = {
			-- Ours win over the colourscheme's. bufferline is "themable" by
			-- default, which means it registers its highlights with
			-- `default = true` and any group a colourscheme already defines
			-- stays put -- kanso.nvim ships BufferLineBufferSelected with no
			-- background, which left the open tab unlifted. We supply a full
			-- palette-built set for every profile, so there is nothing to
			-- defer to.
			themable = false,
			-- Snacks.bufdelete keeps the window layout when a buffer closes.
			close_command = function(n)
				Snacks.bufdelete(n)
			end,
			right_mouse_command = function(n)
				Snacks.bufdelete(n)
			end,
			diagnostics = "nvim_lsp",
			always_show_bufferline = false,
			-- Start the tabs after the file tree instead of drawing over it.
			offsets = {
				{ filetype = "snacks_layout_box", text = "Explorer", highlight = "Directory", text_align = "left" },
			},
		},
	}
end

return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	keys = {
		-- [b / ]b are Neovim's own :bprev / :bnext; these follow the tab order
		-- instead, which changes once buffers are pinned or moved.
		{ "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },
		{ "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
		{ "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer left" },
		{ "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer right" },
		{ "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Pin buffer" },
		{ "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", desc = "Delete unpinned buffers" },
	},
	opts = make_opts,
	config = function(_, opts)
		require("bufferline").setup(opts)
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("dev_setup_bufferline", { clear = true }),
			desc = "Rebuild the tab bar's colours after a theme switch",
			callback = function()
				require("bufferline").setup(make_opts())
			end,
		})
	end,
}

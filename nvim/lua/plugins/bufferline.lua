-- Open buffers as tabs along the top. Hidden while only one buffer is open.
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
	opts = function()
		return {
			highlights = require("catppuccin.special.bufferline").get_theme(),
			options = {
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
	end,
}

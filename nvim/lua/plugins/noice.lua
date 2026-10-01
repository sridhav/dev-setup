-- Replaces the command line, search and message area: `:` and `/` open as a
-- centered popup, long messages go to a split, and LSP hover docs get
-- treesitter highlighting. Notifications still go through snacks' notifier.
return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = { "MunifTanjim/nui.nvim" },
	opts = {
		lsp = {
			-- Render LSP markdown (hover, docs) with treesitter.
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
			},
			-- blink.cmp already shows signature help.
			signature = { enabled = false },
		},
		routes = {
			-- Write / undo / redo messages ("12L, 340B written") go to the small
			-- corner view instead of a popup.
			{
				filter = {
					event = "msg_show",
					any = {
						{ find = "%d+L, %d+B" },
						{ find = "; after #%d+" },
						{ find = "; before #%d+" },
					},
				},
				view = "mini",
			},
		},
		presets = {
			bottom_search = true, -- / and ? stay at the bottom, like Vim
			command_palette = true, -- : popup with the completion menu under it
			long_message_to_split = true,
			lsp_doc_border = true,
		},
	},
	keys = {
		{ "<leader>nl", "<cmd>Noice last<cr>", desc = "Last message" },
		{ "<leader>nh", "<cmd>Noice history<cr>", desc = "Message history" },
		{ "<leader>nd", "<cmd>Noice dismiss<cr>", desc = "Dismiss all" },
		{
			"<S-Enter>",
			function()
				require("noice").redirect(vim.fn.getcmdline())
			end,
			mode = "c",
			desc = "Send command output to a split",
		},
		-- Scroll hover docs; falls back to normal Ctrl-f / Ctrl-b elsewhere.
		{
			"<C-f>",
			function()
				if not require("noice.lsp").scroll(4) then
					return "<C-f>"
				end
			end,
			silent = true,
			expr = true,
			mode = { "i", "n", "s" },
			desc = "Scroll forward",
		},
		{
			"<C-b>",
			function()
				if not require("noice.lsp").scroll(-4) then
					return "<C-b>"
				end
			end,
			silent = true,
			expr = true,
			mode = { "i", "n", "s" },
			desc = "Scroll backward",
		},
	},
}

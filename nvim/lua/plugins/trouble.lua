return {
	"folke/trouble.nvim",
	cmd = "Trouble",
	opts = {
		focus = true, -- move the cursor into the list when it opens
	},
	keys = {
		{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (project)" },
		{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics (buffer)" },
		{ "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols" },
		{
			"<leader>xl",
			"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
			desc = "LSP definitions/references",
		},
		{ "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
		{ "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location list" },
	},
}

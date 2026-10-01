-- Highlights TODO, FIXME, HACK, WARN, PERF and NOTE comments, and lists them.
return {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	event = { "BufReadPost", "BufNewFile" },
	cmd = { "TodoTrouble" },
	opts = {},
	keys = {
		{
			"]t",
			function()
				require("todo-comments").jump_next()
			end,
			desc = "Next todo comment",
		},
		{
			"[t",
			function()
				require("todo-comments").jump_prev()
			end,
			desc = "Previous todo comment",
		},
		{
			"<leader>ft",
			function()
				Snacks.picker.pick("todo_comments", { cwd = require("config.root").get() })
			end,
			desc = "Todo comments",
		},
		{ "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo comments (Trouble)" },
	},
}

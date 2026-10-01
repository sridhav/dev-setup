-- Go debugging through delve (installed by mason). Adds "Debug test" entries,
-- and <leader>Dg debugs the Go test under the cursor.
return {
	"leoluz/nvim-dap-go",
	dependencies = { "mfussenegger/nvim-dap" },
	ft = "go",
	opts = {},
	keys = {
		{
			"<leader>Dg",
			function()
				require("dap-go").debug_test()
			end,
			ft = "go",
			desc = "Debug Go test",
		},
	},
}

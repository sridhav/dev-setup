-- Python debugging through debugpy (installed by mason into its own venv).
-- <leader>Dm debugs the test method under the cursor, <leader>Dk its class.
return {
	"mfussenegger/nvim-dap-python",
	dependencies = { "mfussenegger/nvim-dap" },
	ft = "python",
	config = function()
		require("dap-python").setup(vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python")
	end,
	keys = {
		{
			"<leader>Dm",
			function()
				require("dap-python").test_method()
			end,
			ft = "python",
			desc = "Debug Python test method",
		},
		{
			"<leader>Dk",
			function()
				require("dap-python").test_class()
			end,
			ft = "python",
			desc = "Debug Python test class",
		},
	},
}

-- Scopes, watches, stack and breakpoints panels for nvim-dap. Opens by itself
-- when a debug session starts and closes when it ends.
return {
	"rcarriga/nvim-dap-ui",
	dependencies = { "nvim-neotest/nvim-nio" },
	keys = {
		{
			"<leader>Du",
			function()
				require("dapui").toggle()
			end,
			desc = "Toggle debugger UI",
		},
		{
			"<leader>De",
			function()
				require("dapui").eval()
			end,
			mode = { "n", "x" },
			desc = "Evaluate expression",
		},
	},
	opts = {},
	config = function(_, opts)
		local dap, dapui = require("dap"), require("dapui")
		dapui.setup(opts)
		dap.listeners.after.event_initialized.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end
	end,
}

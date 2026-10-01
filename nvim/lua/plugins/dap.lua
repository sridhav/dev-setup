-- Debugger (Debug Adapter Protocol). Keys live under <leader>D, because
-- <leader>d is line diagnostics. The UI, inline values and the Go/Python
-- adapters are separate files (dap-*.lua); JS/TS has no helper plugin, so its
-- adapter is set up below. Mason installs every adapter (see lsp.lua `tools`).
local function call(fn)
	return function()
		require("dap")[fn]()
	end
end

return {
	"mfussenegger/nvim-dap",
	-- The panels and inline values come up with the debugger.
	dependencies = { "rcarriga/nvim-dap-ui", "theHamsta/nvim-dap-virtual-text" },
	keys = {
		{ "<leader>Db", call("toggle_breakpoint"), desc = "Toggle breakpoint" },
		{
			"<leader>DB",
			function()
				require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end,
			desc = "Conditional breakpoint",
		},
		{ "<leader>Dc", call("continue"), desc = "Start / continue" },
		{ "<leader>DC", call("run_to_cursor"), desc = "Run to cursor" },
		{ "<leader>Di", call("step_into"), desc = "Step into" },
		{ "<leader>DO", call("step_over"), desc = "Step over" },
		{ "<leader>Do", call("step_out"), desc = "Step out" },
		{ "<leader>Dl", call("run_last"), desc = "Run last" },
		{ "<leader>Dp", call("pause"), desc = "Pause" },
		{
			"<leader>Dr",
			function()
				require("dap").repl.toggle()
			end,
			desc = "Toggle REPL",
		},
		{ "<leader>Dt", call("terminate"), desc = "Terminate" },
	},
	config = function()
		vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
		local signs = {
			DapStopped = { "\u{f0055} ", "DiagnosticWarn", "DapStoppedLine" },
			DapBreakpoint = { "\u{f111} ", "DiagnosticInfo" },
			DapBreakpointCondition = { "\u{f059} ", "DiagnosticInfo" },
			DapBreakpointRejected = { "\u{f06a} ", "DiagnosticError" },
			DapLogPoint = { ".>", "DiagnosticInfo" },
		}
		for name, sign in pairs(signs) do
			vim.fn.sign_define(name, { text = sign[1], texthl = sign[2], linehl = sign[3], numhl = sign[3] })
		end

		-- JavaScript / TypeScript through mason's js-debug-adapter (VS Code's).
		local dap = require("dap")
		dap.adapters["pwa-node"] = {
			type = "server",
			host = "localhost",
			port = "${port}",
			executable = { command = "js-debug-adapter", args = { "${port}" } },
		}
		for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
			dap.configurations[ft] = {
				{
					type = "pwa-node",
					request = "launch",
					name = "Launch file",
					program = "${file}",
					cwd = "${workspaceFolder}",
				},
				{
					type = "pwa-node",
					request = "attach",
					name = "Attach to process",
					processId = require("dap.utils").pick_process,
					cwd = "${workspaceFolder}",
				},
			}
		end
	end,
}

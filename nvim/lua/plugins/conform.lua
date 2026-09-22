return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = { "n", "v" },
			desc = "Format buffer",
		},
		{
			"<leader>tf",
			function()
				vim.g.disable_autoformat = not vim.g.disable_autoformat
				vim.notify("Format on save: " .. (vim.g.disable_autoformat and "off" or "on"))
			end,
			desc = "Toggle format on save",
		},
	},
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			terraform = { "terraform_fmt" },
			tf = { "terraform_fmt" },
			hcl = { "terraform_fmt" },
			yaml = { "yamlfmt" },
			json = { "jq" },
			jsonc = { "jq" },
			sh = { "shfmt" },
			bash = { "shfmt" },
			go = { "gofmt" },
			python = { "isort", "black" },
			rust = { "rustfmt" },
			-- prefer prettierd, fall back to prettier if the daemon isn't installed
			javascript = { "prettierd", "prettier", stop_after_first = true },
			javascriptreact = { "prettierd", "prettier", stop_after_first = true },
			typescript = { "prettierd", "prettier", stop_after_first = true },
			typescriptreact = { "prettierd", "prettier", stop_after_first = true },
			markdown = { "prettierd", "prettier", stop_after_first = true },
		},
		default_format_opts = { lsp_format = "fallback" },
		format_on_save = function(bufnr)
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end
			return { timeout_ms = 1000, lsp_format = "fallback" }
		end,
	},
}

local servers = {
	"lua_ls",
	"terraformls",
	"dockerls",
	"yamlls",
	"bashls",
	"pyright",
	"jsonls",
	"gopls",
	"helm_ls",
	"marksman",
	"vtsls", -- TypeScript / JavaScript
	"ruff", -- Python lint + quick fixes; pyright keeps types and hover
	"docker_compose_language_service",
}

-- Tools mason should have on disk for conform/nvim-lint/nvim-dap to call.
local tools = {
	"selene",
	"hadolint",
	"tflint",
	"shellcheck",
	"shfmt",
	"yamllint",
	"yamlfmt",
	"actionlint",
	"prettierd",
	"eslint_d",
	"stylua",
	"goimports",
	"golangci-lint",
	"markdownlint-cli2",
	-- debug adapters (dap*.lua)
	"delve",
	"debugpy",
	"js-debug-adapter",
}

return {
	{
		"mason-org/mason.nvim",
		cmd = { "Mason", "MasonInstall", "MasonToolsInstall" },
		opts = {},
		config = function(_, opts)
			require("mason").setup(opts)

			local function install_missing()
				local registry = require("mason-registry")
				registry.refresh(function()
					for _, tool in ipairs(tools) do
						local ok, pkg = pcall(registry.get_package, tool)
						if not ok then
							vim.notify("mason: unknown package " .. tool, vim.log.levels.WARN)
						elseif not pkg:is_installed() then
							pkg:install()
						end
					end
				end)
			end

			vim.api.nvim_create_user_command("MasonToolsInstall", install_missing, {})
			-- registry.refresh() hits the network. Defer it off the startup path so
			-- it never delays the first paint.
			vim.defer_fn(install_missing, 2000)
		end,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		-- Enable only the servers listed above. `true` would enable every
		-- installed mason package that has an lspconfig entry, which starts tools
		-- like tflint and stylua as LSP servers on top of nvim-lint and conform.
		opts = {
			ensure_installed = servers,
			automatic_enable = servers,
		},
	},
	{
		"neovim/nvim-lspconfig",
		lazy = true,
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
				callback = function(ev)
					local function map(keys, fn, desc)
						vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = "LSP: " .. desc })
					end
					-- Neovim 0.11+ already provides grn/gra/grr/gri/K; these add the
					-- picker-backed lists and the conventional `gd`.
					map("gd", function()
						Snacks.picker.lsp_definitions()
					end, "Goto definition")
					map("gr", function()
						Snacks.picker.lsp_references()
					end, "References")
					map("gI", function()
						Snacks.picker.lsp_implementations()
					end, "Goto implementation")
					map("<leader>ds", function()
						Snacks.picker.lsp_symbols()
					end, "Document symbols")
					map("<leader>ws", function()
						Snacks.picker.lsp_workspace_symbols()
					end, "Workspace symbols")
					map("gD", vim.lsp.buf.declaration, "Goto declaration")
					map("<leader>rn", vim.lsp.buf.rename, "Rename")
					map("<leader>ca", vim.lsp.buf.code_action, "Code action")

					-- Highlighting other uses of the word under the cursor is
					-- snacks' `words` (]] / [[ jump between them).

					local client = vim.lsp.get_client_by_id(ev.data.client_id)
					if not client then
						return
					end
					-- pyright's hover is the useful one; ruff's would show up twice.
					if client.name == "ruff" then
						client.server_capabilities.hoverProvider = false
					end
					-- Inlay hints (parameter names, inferred types) on by default;
					-- <leader>th toggles them.
					if client:supports_method("textDocument/inlayHint") then
						vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
					end
				end,
			})
		end,
	},
}

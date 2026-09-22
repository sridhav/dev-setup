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
}

-- Tools mason should have on disk for conform/nvim-lint to call.
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
	"black",
	"isort",
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
					-- Telescope-backed pickers and the conventional `gd`.
					local ok, builtin = pcall(require, "telescope.builtin")
					if ok then
						map("gd", builtin.lsp_definitions, "Goto definition")
						map("gr", builtin.lsp_references, "References")
						map("gI", builtin.lsp_implementations, "Goto implementation")
						map("<leader>ds", builtin.lsp_document_symbols, "Document symbols")
						map("<leader>ws", builtin.lsp_dynamic_workspace_symbols, "Workspace symbols")
					else
						map("gd", vim.lsp.buf.definition, "Goto definition")
						map("gr", vim.lsp.buf.references, "References")
					end
					map("gD", vim.lsp.buf.declaration, "Goto declaration")
					map("<leader>rn", vim.lsp.buf.rename, "Rename")
					map("<leader>ca", vim.lsp.buf.code_action, "Code action")

					local client = vim.lsp.get_client_by_id(ev.data.client_id)
					if client and client:supports_method("textDocument/documentHighlight") then
						local grp = vim.api.nvim_create_augroup("lsp_highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold" }, {
							buffer = ev.buf,
							group = grp,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved" }, {
							buffer = ev.buf,
							group = grp,
							callback = vim.lsp.buf.clear_references,
						})
					end
				end,
			})
		end,
	},
}

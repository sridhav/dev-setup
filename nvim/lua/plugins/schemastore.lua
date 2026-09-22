return {
	"b0o/SchemaStore.nvim",
	-- Load before LSP servers attach: vim.lsp.config() is read when a server
	-- starts on FileType, which fires after BufReadPre.
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local schemastore = require("schemastore")

		local yaml_schemas = schemastore.yaml.schemas()
		-- Kubernetes manifests can't be recognised by filename alone, so point
		-- yamlls's built-in Kubernetes schema at the usual manifest directories.
		yaml_schemas.kubernetes = {
			"k8s/**/*.{yml,yaml}",
			"kubernetes/**/*.{yml,yaml}",
			"manifests/**/*.{yml,yaml}",
			"deploy/**/*.{yml,yaml}",
		}

		vim.lsp.config("yamlls", {
			settings = {
				yaml = {
					-- Disable yamlls's own schema fetching; SchemaStore.nvim supplies them.
					schemaStore = { enable = false, url = "" },
					schemas = yaml_schemas,
					validate = true,
					completion = true,
					hover = true,
				},
			},
		})

		vim.lsp.config("jsonls", {
			settings = {
				json = {
					schemas = schemastore.json.schemas(),
					validate = { enable = true },
				},
			},
		})
	end,
}

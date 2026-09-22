return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	-- Also renders the <leader>k cheat sheet, which is a markdown buffer.
	ft = { "markdown" },
	opts = {
		-- Headings, tables, checkboxes and code blocks render in place; the line
		-- under the cursor shows raw markdown so it stays editable.
		completions = { lsp = { enabled = true } }, -- checkbox/callout items in blink.cmp
		-- LaTeX needs extra system tools (utftex / pylatexenc) we don't install.
		latex = { enabled = false },
	},
	keys = {
		{ "<leader>tm", "<cmd>RenderMarkdown buf_toggle<cr>", ft = "markdown", desc = "Toggle markdown rendering" },
		{ "<leader>mp", "<cmd>RenderMarkdown preview<cr>", ft = "markdown", desc = "Markdown preview in a side split" },
	},
}

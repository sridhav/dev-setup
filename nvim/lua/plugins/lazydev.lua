-- Teaches lua_ls the Neovim API and the installed plugins while editing this
-- config: completion for vim.*, go-to-definition into plugin code, and real
-- "undefined global" warnings (this replaced a .luarc.json that silenced them).
return {
	"folke/lazydev.nvim",
	ft = "lua",
	opts = {
		library = {
			-- Only loaded when the file mentions the word, to keep lua_ls fast.
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			{ path = "snacks.nvim", words = { "Snacks" } },
		},
	},
}

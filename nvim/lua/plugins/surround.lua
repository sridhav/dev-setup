-- Add, change and delete the thing *around* text: quotes, brackets, tags.
--   cs"'   "word" -> 'word'        ds(   (word) -> word
--   ysiw)  word   -> (word)        gs)   in visual mode, wrap the selection
return {
	"kylechui/nvim-surround",
	version = "*",
	event = "VeryLazy",
	init = function()
		-- v4 sets its keymaps itself, not through setup(). Drop only the visual
		-- defaults: they would take S from flash.nvim, which owns s/S/r/R.
		-- Normal mode keeps the usual ys / cs / ds.
		vim.g.nvim_surround_no_visual_mappings = true
	end,
	config = function()
		require("nvim-surround").setup({})
		vim.keymap.set("x", "gs", "<Plug>(nvim-surround-visual)", { desc = "Surround selection" })
		vim.keymap.set("x", "gS", "<Plug>(nvim-surround-visual-line)", { desc = "Surround selection (line)" })
	end,
}

-- Vim's undo history is a tree, not a line: undo, type something new, and the
-- old branch still exists but is invisible. This makes it navigable.
-- opt.undofile (vim-options.lua) keeps that history across restarts.
return {
	"mbbill/undotree",
	cmd = "UndotreeToggle",
	keys = {
		{ "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Undo tree" },
	},
	init = function()
		vim.g.undotree_SetFocusWhenToggle = 1
	end,
}

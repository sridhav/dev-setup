return {
	"kdheepak/lazygit.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	cmd = {
		"LazyGit",
		"LazyGitConfig",
		"LazyGitCurrentFile",
		"LazyGitFilter",
		"LazyGitFilterCurrentFile",
	},
	init = function()
		vim.g.lazygit_floating_window_scaling_factor = 0.9
	end,
	keys = {
		{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
		{ "<leader>gf", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit (current file's repo)" },
		{ "<leader>gl", "<cmd>LazyGitFilterCurrentFile<cr>", desc = "Commits touching current file" },
	},
}

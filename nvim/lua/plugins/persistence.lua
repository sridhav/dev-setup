return {
	"folke/persistence.nvim",
	-- Starts recording the session once a real file is opened.
	event = "BufReadPre",
	opts = {},
	init = function()
		-- A saved file-tree window restores as an empty, broken buffer, so close
		-- the tree before persistence writes the session.
		vim.api.nvim_create_autocmd("User", {
			pattern = "PersistenceSavePre",
			group = vim.api.nvim_create_augroup("persistence_explorer", { clear = true }),
			callback = function()
				for _, explorer in ipairs(Snacks.picker.get({ source = "explorer" })) do
					explorer:close()
				end
			end,
		})
	end,
	keys = {
		{
			"<leader>Ss",
			function()
				require("persistence").load()
			end,
			desc = "Restore session (cwd)",
		},
		{
			"<leader>SS",
			function()
				require("persistence").select()
			end,
			desc = "Pick a session",
		},
		{
			"<leader>Sl",
			function()
				require("persistence").load({ last = true })
			end,
			desc = "Restore last session",
		},
		{
			"<leader>Sd",
			function()
				require("persistence").stop()
			end,
			desc = "Don't save this session",
		},
	},
}

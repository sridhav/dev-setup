-- Search and replace across the project, with a live preview of every change.
-- Uses ripgrep. Edit the result lines directly; <localleader>r replaces all.
return {
	"MagicDuck/grug-far.nvim",
	cmd = { "GrugFar", "GrugFarWithin" },
	opts = { headerMaxWidth = 80 },
	keys = {
		{
			"<leader>sr",
			function()
				-- Start filtered to this file's extension; clear the filter to widen it.
				local ext = vim.bo.buftype == "" and vim.fn.expand("%:e") or ""
				require("grug-far").open({
					transient = true,
					prefills = { filesFilter = ext ~= "" and "*." .. ext or nil },
				})
			end,
			mode = { "n", "x" },
			desc = "Search and replace",
		},
	},
}

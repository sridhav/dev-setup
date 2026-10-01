-- Pins the enclosing function/class signature to the top of the window while
-- its body scrolls past. Uses Neovim's own treesitter, so it works with
-- nvim-treesitter's `main` branch.
return {
	"nvim-treesitter/nvim-treesitter-context",
	event = { "BufReadPost", "BufNewFile" },
	opts = { mode = "cursor", max_lines = 3 },
	config = function(_, opts)
		local tsc = require("treesitter-context")
		tsc.setup(opts)
		Snacks.toggle({
			name = "Treesitter context",
			get = tsc.enabled,
			set = function(state)
				if state then
					tsc.enable()
				else
					tsc.disable()
				end
			end,
		}):map("<leader>tc")
	end,
}

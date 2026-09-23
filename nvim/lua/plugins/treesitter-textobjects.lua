-- Select and jump by syntax, not by guessing where a function ends.
--   vif / vaf   select inside / around a function
--   vic / vac   the same for a class
--   via / vaa   an argument
--   ]f / [f     jump to the next / previous function
--
-- Must track nvim-treesitter's `main` branch: the master API it replaced does
-- not exist there (see treesitter.lua), and mixing the two silently no-ops.
return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	branch = "main",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	event = "VeryLazy",
	config = function()
		require("nvim-treesitter-textobjects").setup({
			select = { lookahead = true },
			move = { set_jumps = true },
		})

		local select = require("nvim-treesitter-textobjects.select")
		-- a = around (includes the signature/braces), i = inside (just the body).
		local objects = {
			f = "function",
			c = "class",
			a = "parameter",
		}
		for key, name in pairs(objects) do
			for _, kind in ipairs({ "outer", "inner" }) do
				local lhs = (kind == "outer" and "a" or "i") .. key
				vim.keymap.set({ "x", "o" }, lhs, function()
					select.select_textobject("@" .. name .. "." .. kind, "textobjects")
				end, { desc = (kind == "outer" and "Around " or "Inside ") .. name })
			end
		end

		local move = require("nvim-treesitter-textobjects.move")
		vim.keymap.set({ "n", "x", "o" }, "]f", function()
			move.goto_next_start("@function.outer", "textobjects")
		end, { desc = "Next function" })
		vim.keymap.set({ "n", "x", "o" }, "[f", function()
			move.goto_previous_start("@function.outer", "textobjects")
		end, { desc = "Previous function" })
	end,
}

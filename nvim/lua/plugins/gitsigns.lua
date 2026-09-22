return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		signs = {
			add = { text = "▎" },
			change = { text = "▎" },
			delete = { text = "" },
			topdelete = { text = "" },
			changedelete = { text = "▎" },
			untracked = { text = "▎" },
		},
		current_line_blame_opts = { delay = 300 },
		on_attach = function(bufnr)
			local gs = require("gitsigns")
			local function map(mode, keys, fn, desc)
				vim.keymap.set(mode, keys, fn, { buffer = bufnr, desc = desc })
			end

			-- In diff mode keep Vim's native ]c/[c change navigation.
			map("n", "]c", function()
				if vim.wo.diff then
					return vim.cmd.normal({ "]c", bang = true })
				end
				gs.nav_hunk("next")
			end, "Next hunk")
			map("n", "[c", function()
				if vim.wo.diff then
					return vim.cmd.normal({ "[c", bang = true })
				end
				gs.nav_hunk("prev")
			end, "Previous hunk")

			map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
			map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
			map("v", "<leader>hs", function()
				gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, "Stage selection")
			map("v", "<leader>hr", function()
				gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, "Reset selection")
			map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
			map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
			map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
			map("n", "<leader>hb", function()
				gs.blame_line({ full = true })
			end, "Blame line")
			map("n", "<leader>hd", gs.diffthis, "Diff against index")
			map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle inline blame")
			map({ "o", "x" }, "ih", gs.select_hunk, "Select hunk")
		end,
	},
}

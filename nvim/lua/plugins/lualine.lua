-- Nerd Font glyphs as escapes so the file stays plain ASCII.
local round_l, round_r = "\u{e0b6}", "\u{e0b4}"

-- Names of the LSP servers attached to the current buffer.
local function lsp_clients()
	local names = vim.tbl_map(function(c)
		return c.name
	end, vim.lsp.get_clients({ bufnr = 0 }))
	return #names > 0 and ("\u{f085} " .. table.concat(names, ", ")) or ""
end

-- Shown only while a macro is being recorded.
local function macro_recording()
	local reg = vim.fn.reg_recording()
	return reg ~= "" and ("\u{f111} recording @" .. reg) or ""
end

-- Reuse gitsigns' counts instead of lualine running its own git diff.
local function gitsigns_diff()
	local g = vim.b.gitsigns_status_dict
	if g then
		return { added = g.added, modified = g.changed, removed = g.removed }
	end
end

return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	opts = {
		options = {
			theme = "auto", -- follows the active colorscheme (catppuccin ships its own)
			globalstatus = true,
			-- "Bubble" style: rounded ends, matching the rounded tmux window tabs.
			section_separators = { left = round_r, right = round_l },
			component_separators = "",
		},
		sections = {
			lualine_a = {
				{ "mode", icon = "\u{e7c5}", separator = { left = round_l }, padding = { left = 0, right = 1 } },
			},
			lualine_b = {
				{ "branch", icon = "\u{e725}" },
				{
					"diff",
					source = gitsigns_diff,
					symbols = { added = "\u{f0fe} ", modified = "\u{f14b} ", removed = "\u{f146} " },
				},
			},
			lualine_c = {
				{ "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
				{
					"filename",
					path = 1,
					symbols = { modified = " \u{25cf}", readonly = " \u{f023}", unnamed = "[No Name]" },
				},
				{
					"diagnostics",
					symbols = { error = "\u{f015a} ", warn = "\u{f002a} ", info = "\u{f02fd} ", hint = "\u{f0336} " },
				},
			},
			lualine_x = {
				{ macro_recording, color = { fg = "#f38ba8", gui = "bold" } },
				{ lsp_clients },
			},
			lualine_y = {
				{ "progress" },
			},
			lualine_z = {
				{ "location", separator = { right = round_r }, padding = { left = 1, right = 0 } },
			},
		},
		-- Tailored bars when neo-tree, lazy, mason or trouble has focus.
		extensions = { "neo-tree", "lazy", "mason", "trouble" },
	},
}

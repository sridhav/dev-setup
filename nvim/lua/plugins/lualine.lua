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

-- The snacks terminal (Ctrl-/). oh-my-zsh sets its title to "user@host:dir"
-- while the shell waits and to the command line while one runs. Without a
-- title Neovim falls back to the buffer name (term://...).
local function term_title()
	local title = vim.b.term_title or ""
	return title:find("^term://") and "" or title
end

-- The shell's directory. While a command runs the title holds the command, so
-- show the last directory seen (or the one the terminal opened in).
local function term_dir()
	local dir = term_title():match("^[^@:]+@[^:]+:(.+)$")
	if dir then
		vim.b.term_last_dir = dir
	end
	local info = vim.b.snacks_terminal or {}
	return vim.fn.fnamemodify(dir or vim.b.term_last_dir or info.cwd or vim.fn.getcwd(), ":~")
end

-- The running command, or the shell's name while it waits.
local function term_command()
	local title = term_title()
	if title == "" or title:match("^[^@:]+@[^:]+:") then
		local cmd = (vim.b.snacks_terminal or {}).cmd
		cmd = type(cmd) == "table" and cmd[1] or cmd or vim.o.shell
		return vim.fn.fnamemodify(cmd:match("^%S+"), ":t")
	end
	return title
end

-- Which terminal this is: "#1", or "#2/3" when several are open. snacks keeps
-- them unordered, so number them in the order they were opened.
local function term_number()
	local terms = Snacks.terminal.list()
	table.sort(terms, function(a, b)
		return a.buf < b.buf
	end)
	for i, term in ipairs(terms) do
		if term.buf == vim.api.nvim_get_current_buf() then
			return "#" .. i .. (#terms > 1 and ("/" .. #terms) or "")
		end
	end
	return ""
end

-- Terminal mode is typing into the shell; normal mode scrolls and copies.
local function term_mode()
	return vim.fn.mode() == "t" and "TERMINAL" or "SCROLL"
end

-- Same bubbles as the editor bar, with what makes sense in a shell: the
-- running command, the shell's directory and which terminal this is.
local function terminal(branch_color, folder_color, end_color)
	return {
		filetypes = { "snacks_terminal" },
		sections = {
			lualine_a = {
				{ term_mode, icon = "\u{e795}", separator = { left = round_l }, padding = { left = 0, right = 1 } },
			},
			lualine_b = { { "branch", icon = "\u{e725}", color = branch_color } },
			lualine_c = { { term_command, icon = "\u{f120}" } },
			lualine_y = { { term_dir, icon = "\u{f07b}", color = folder_color } },
			lualine_z = {
				{
					term_number,
					icon = "\u{f489}",
					color = end_color,
					separator = { right = round_r },
					padding = { left = 1, right = 0 },
				},
			},
		},
	}
end

return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	opts = function()
		-- Breadcrumbs: where the cursor is in the code (module > class > function),
		-- from trouble's LSP symbols.
		-- One color per kind of item, the same in the tmux bar: branch mauve,
		-- folder peach, position teal. Only the mode bubble follows the mode.
		local C = require("catppuccin.palettes").get_palette("mocha")
		local branch_color = { fg = C.mauve }
		local folder_color = { fg = C.peach }
		local end_color = { fg = C.crust, bg = C.teal, gui = "bold" }

		local symbols = require("trouble").statusline({
			mode = "symbols",
			groups = {},
			title = false,
			filter = { range = true },
			format = "{kind_icon}{symbol.name:Normal}",
			hl_group = "lualine_c_normal",
		})

		return {
			options = {
				theme = "auto", -- follows the active colorscheme (catppuccin ships its own)
				globalstatus = true,
				-- "Bubble" style: rounded ends, the same bubbles as the tmux bar.
				section_separators = { left = round_r, right = round_l },
				component_separators = "",
			},
			sections = {
				lualine_a = {
					{ "mode", icon = "\u{e7c5}", separator = { left = round_l }, padding = { left = 0, right = 1 } },
				},
				lualine_b = {
					{ "branch", icon = "\u{e725}", color = branch_color },
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
						symbols = {
							error = "\u{f015a} ",
							warn = "\u{f002a} ",
							info = "\u{f02fd} ",
							hint = "\u{f0336} ",
						},
					},
					{ symbols.get, cond = symbols.has },
				},
				lualine_x = {
					{ macro_recording, color = { fg = "#f38ba8", gui = "bold" } },
					{ lsp_clients, color = { fg = C.lavender } },
				},
				-- The project folder, like the directory bubble in the tmux bar.
				lualine_y = {
					{
						function()
							return vim.fn.fnamemodify(require("config.root").get(), ":t")
						end,
						icon = "\u{f07b}",
						color = folder_color,
					},
				},
				lualine_z = {
					{
						function() -- line:column, without lualine's padding
							return vim.fn.line(".") .. ":" .. vim.fn.virtcol(".")
						end,
						icon = "\u{e0a1}",
						color = end_color,
						separator = { right = round_r },
						padding = { left = 1, right = 0 },
					},
				},
			},
			-- Tailored bars when lazy, mason, trouble or the terminal has focus.
			extensions = { "lazy", "mason", "trouble", terminal(branch_color, folder_color, end_color) },
		}
	end,
}

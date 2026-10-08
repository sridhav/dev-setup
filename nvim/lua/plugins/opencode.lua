-- opencode in Neovim. It adds no chat UI of its own: prompts carry the editor's
-- context (@this, @buffer, @diagnostics, @quickfix, …) to a running opencode
-- server, and buffers reload in place as opencode edits them. The input box and
-- the prompt picker are snacks.input / snacks.picker, both already on in
-- plugins/snacks.lua.
--
-- The `opencode` CLI comes from FORMULAE in sh/packages.sh. Its theme is tracked
-- in opencode/tui.json; providers and MCP tokens stay machine-only in
-- ~/.config/opencode/opencode.json.
local opencode_cmd = "opencode"

---@type snacks.terminal.Opts
local term_opts = { win = { position = "right", enter = false } }

return {
	"nickjvandyke/opencode.nvim",
	-- main follows opencode v2, which is what Homebrew installs. (`version = "*"`
	-- would pin to the v1 releases instead.)
	-- Loaded early rather than on a key, so its event listener is in place and
	-- buffers reload even when opencode is driven from its own TUI.
	event = "VeryLazy",
	config = function()
		---@type opencode.Opts
		vim.g.opencode_opts = {
			server = {
				-- Start opencode in the same terminal <leader>ot toggles, so there is
				-- never a second instance running out of sight.
				start = function()
					require("snacks.terminal").open(opencode_cmd, term_opts)
				end,
			},
		}

		-- Reveal that terminal once opencode starts working on a prompt.
		vim.api.nvim_create_autocmd("User", {
			pattern = "OpencodeEvent:session.execution.started",
			callback = function()
				local win = require("snacks.terminal").get(opencode_cmd, { create = false })
				if win then
					win:show()
				end
			end,
		})
	end,
	keys = {
		{
			"<leader>oa",
			function()
				require("opencode").ask("@this: ")
			end,
			mode = { "n", "x" },
			desc = "opencode: ask about this",
		},
		{
			"<leader>oA",
			function()
				require("opencode").ask()
			end,
			mode = { "n", "x" },
			desc = "opencode: ask",
		},
		{
			"<leader>os",
			function()
				require("opencode").select()
			end,
			mode = { "n", "x" },
			desc = "opencode: select a prompt",
		},
		{
			"<leader>oc",
			function()
				require("opencode").command()
			end,
			desc = "opencode: run a command",
		},
		-- An operator, so it takes a motion and repeats with `.` ( <leader>oo_ = line ).
		{
			"<leader>oo",
			function()
				return require("opencode").operator("@this")
			end,
			mode = { "n", "x" },
			expr = true,
			desc = "opencode: send range",
		},
		-- Normal mode only: a <leader> map in terminal mode would delay every
		-- leader keypress while typing inside opencode. <Esc><Esc> leaves the
		-- terminal first.
		{
			"<leader>ot",
			function()
				require("snacks.terminal").toggle(opencode_cmd, term_opts)
			end,
			desc = "opencode: toggle terminal",
		},
	},
}

-- Claude Code in Neovim. Speaks the same WebSocket/MCP protocol as Anthropic's
-- VS Code extension, so Claude sees the current selection and the diagnostics,
-- and its edits arrive as a diff to accept or reject instead of silent writes.
-- Needs the `claude` CLI (sh/steps/16-claude-code.sh installs it).
--
-- Keys live under <leader>c, shared with the LSP "code" group; <leader>ca stays
-- code action.
return {
	"coder/claudecode.nvim",
	dependencies = { "folke/snacks.nvim" }, -- the terminal split Claude runs in
	-- cmd so the :ClaudeCode* commands exist on a fresh start; without it a
	-- keys-only spec defers loading until a <leader>c key is pressed.
	cmd = {
		"ClaudeCode",
		"ClaudeCodeFocus",
		"ClaudeCodeSelectModel",
		"ClaudeCodeAdd",
		"ClaudeCodeSend",
		"ClaudeCodeTreeAdd",
		"ClaudeCodeStatus",
		"ClaudeCodeStart",
		"ClaudeCodeStop",
		"ClaudeCodeDiffAccept",
		"ClaudeCodeDiffDeny",
		"ClaudeCodeCloseAllDiffs",
	},
	opts = {}, -- defaults: the plugin finds `claude` on PATH and picks its own port
	keys = {
		{ "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Claude: toggle" },
		{ "<leader>cf", "<cmd>ClaudeCodeFocus<cr>", desc = "Claude: focus" },
		{ "<leader>cr", "<cmd>ClaudeCode --resume<cr>", desc = "Claude: resume a session" },
		{ "<leader>cC", "<cmd>ClaudeCode --continue<cr>", desc = "Claude: continue last session" },
		{ "<leader>cm", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Claude: select model" },
		{ "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Claude: add this buffer" },
		{ "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "x", desc = "Claude: send selection" },
		-- Same key in the snacks explorer/picker adds the file under the cursor.
		{
			"<leader>cs",
			"<cmd>ClaudeCodeTreeAdd<cr>",
			ft = { "snacks_picker_list", "snacks_layout_box" },
			desc = "Claude: add file",
		},
		{ "<leader>cA", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude: accept diff" },
		{ "<leader>cd", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Claude: deny diff" },
	},
}

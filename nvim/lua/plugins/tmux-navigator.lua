return {
	"christoomey/vim-tmux-navigator",
	cmd = {
		"TmuxNavigateLeft",
		"TmuxNavigateDown",
		"TmuxNavigateUp",
		"TmuxNavigateRight",
		"TmuxNavigatePrevious",
	},
	-- Same keys move between Neovim splits and tmux panes; needs the matching
	-- christoomey/vim-tmux-navigator plugin in ~/.tmux.conf.
	keys = {
		{ "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Window/pane left" },
		{ "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Window/pane down" },
		{ "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Window/pane up" },
		{ "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Window/pane right" },
		{ "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Previous window/pane" },
		-- Same moves on Ctrl-Shift-arrows. Plain Ctrl-arrows are not used: they
		-- are macOS Spaces/Mission Control shortcuts, and Vim's own back/forward
		-- a word.
		{ "<C-S-Left>", "<cmd>TmuxNavigateLeft<cr>", desc = "Window/pane left" },
		{ "<C-S-Down>", "<cmd>TmuxNavigateDown<cr>", desc = "Window/pane down" },
		{ "<C-S-Up>", "<cmd>TmuxNavigateUp<cr>", desc = "Window/pane up" },
		{ "<C-S-Right>", "<cmd>TmuxNavigateRight<cr>", desc = "Window/pane right" },
	},
}

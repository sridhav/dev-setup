-- Closes HTML/JSX/TSX tags as you type them, and renames the closing tag when
-- the opening one changes.
return {
	"windwp/nvim-ts-autotag",
	event = { "BufReadPre", "BufNewFile" },
	opts = {},
}

-- Close brackets and quotes as you type. check_ts keeps it quiet inside
-- strings and comments, using the treesitter parsers we already install.
return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	opts = {
		check_ts = true,
		fast_wrap = {},
	},
}

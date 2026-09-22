return {
	"saghen/blink.cmp",
	build = function()
		require("blink.cmp").build():pwait()
	end,
	dependencies = {
		"saghen/blink.lib",
		"rafamadriz/friendly-snippets",
	},
	version = "*",
	event = "InsertEnter",
	opts = {
		-- The Rust matcher is built by the `build` hook above; only fall back to
		-- the (much slower) Lua one if that build failed.
		fuzzy = { implementation = "prefer_rust_with_warning" },
		keymap = { preset = "default" },
		appearance = { nerd_font_variant = "mono" },
		completion = {
			documentation = { auto_show = true, auto_show_delay_ms = 200 },
			ghost_text = { enabled = true },
		},
		signature = { enabled = true },
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},
	},
}

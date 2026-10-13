-- The light half of the "scleral" profile (sh/theme.sh --scleral).
--
-- Chosen because it is the most desaturated palette of the 463 Ghostty ships:
-- saturated accents are what cause coloured ghosting when the cornea scatters
-- light, so a deliberately colourless theme is easier to read, not just calmer.
--
-- Its own `dark` is high-contrast, so the profile pairs it with Kanagawa Dragon
-- instead; `dim` is kept here as the low-contrast in-family fallback.
-- Applied by lua/config/theme.lua, never by this file.
return {
	"aktersnurra/no-clown-fiesta.nvim",
	lazy = false,
	priority = 900,
	opts = {
		-- The upstream light variant is marked "under development": expect the
		-- odd unstyled plugin highlight rather than wrong code colours.
		theme = "light",
		transparent = false,
		styles = {
			comments = {},
			keywords = {},
			functions = {},
			variables = {},
			type = { bold = true },
			lsp = { underline = false },
		},
	},
	config = function(_, opts)
		require("no-clown-fiesta").setup(opts)
	end,
}

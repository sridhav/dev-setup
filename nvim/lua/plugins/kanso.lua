-- The light half of the "scleral" profile (sh/theme.sh --scleral).
--
-- Kanso Pearl: a warm, low-saturation light theme. Saturated accents are what
-- cause coloured ghosting when the cornea scatters light, so a muted palette
-- is easier to read, not just calmer -- the same reason this profile exists.
--
-- The plugin carries four variants; `kanso-pearl` is the one colourscheme name
-- that pins the light one (plain `kanso` would follow 'background' instead,
-- and this profile's dark half is Kanagawa Dragon, not Kanso Ink).
-- Applied by lua/config/theme.lua, never by this file.
return {
	"webhooked/kanso.nvim",
	lazy = false,
	priority = 900,
	opts = {
		bold = true,
		italics = true,
		undercurl = true,
		transparent = false,
		dimInactive = false,
		terminalColors = true,
		commentStyle = { italic = true },
		keywordStyle = { italic = true },
	},
	config = function(_, opts)
		require("kanso").setup(opts)
	end,
}

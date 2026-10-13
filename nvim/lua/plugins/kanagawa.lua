-- The dark half of the "scleral" profile (sh/theme.sh --scleral).
--
-- Dragon, not Wave: it is the muted low-contrast variant, which is the point.
-- Bright text on a dark ground is what blooms when light scatters, so the dark
-- half is chosen for a grey-not-black background and softened foreground.
-- Applied by lua/config/theme.lua, never by this file.
return {
	"rebelot/kanagawa.nvim",
	lazy = false,
	priority = 900,
	opts = {
		compile = false,
		dimInactive = false,
		background = { dark = "dragon", light = "lotus" },
	},
	config = function(_, opts)
		require("kanagawa").setup(opts)
	end,
}

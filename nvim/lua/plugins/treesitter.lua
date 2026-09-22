local ensure_installed = {
	"bash",
	"css",
	"diff",
	"dockerfile",
	"git_config",
	"gitcommit",
	"go",
	"gomod",
	"hcl",
	"html",
	"javascript",
	"json",
	"lua",
	"luadoc",
	"markdown",
	"markdown_inline",
	"python",
	"query",
	"regex",
	"terraform",
	"toml",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"yaml",
}

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main", -- pin explicitly: the master/main APIs are incompatible
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").setup()

		-- `auto_install` no longer exists on main; install missing parsers ourselves.
		local installed = require("nvim-treesitter.config").get_installed("parsers")
		local missing = vim.tbl_filter(function(lang)
			return not vim.tbl_contains(installed, lang)
		end, ensure_installed)
		-- The `main` branch compiles parsers with the tree-sitter CLI; without it
		-- every install fails with an ENOENT. Warn once instead of spamming.
		if #missing > 0 then
			if vim.fn.executable("tree-sitter") == 1 then
				require("nvim-treesitter").install(missing)
			else
				vim.notify(
					"nvim-treesitter (main) needs the tree-sitter CLI: brew install tree-sitter-cli",
					vim.log.levels.WARN
				)
			end
		end

		-- On main, highlighting/indent are opt-in per buffer via vim.treesitter.
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
			callback = function(ev)
				local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
				-- language.add() returns nil (it does not throw) when no parser exists,
				-- e.g. netrw or plugin UI buffers, so check its result, not pcall's.
				if not lang then
					return
				end
				local ok, loaded = pcall(vim.treesitter.language.add, lang)
				if not ok or not loaded then
					return
				end
				vim.treesitter.start(ev.buf, lang)
				vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}

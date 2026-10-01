return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			lua = { "selene" },
			dockerfile = { "hadolint" },
			yaml = { "yamllint" },
			terraform = { "tflint" },
			go = { "golangcilint" },
			markdown = { "markdownlint-cli2" },
			sh = { "shellcheck" },
			bash = { "shellcheck" },
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
		}

		-- markdownlint's defaults flag every line over 80 characters and every
		-- compact table. markdownlint.yaml (next to init.lua) turns those two
		-- off; a project's own .markdownlint* config still applies on top.
		lint.linters["markdownlint-cli2"].args = {
			"--config",
			vim.fn.stdpath("config") .. "/markdownlint.yaml",
			"-",
		}

		-- Without a selene.toml, selene checks plain Lua 5.1: `vim` is unknown and
		-- every lazy.nvim spec is a warning. Run it only where a project set it up.
		local function has_selene_config(path)
			return vim.fs.find({ "selene.toml" }, { path = vim.fs.dirname(path), upward = true })[1] ~= nil
		end

		-- GitHub workflow files get the compound filetype `yaml.github`, not
		-- `githubaction`, and nvim-lint resolves that to the `yaml` entry above.
		-- Match them by path instead so actionlint actually runs.
		local function linters_for_buf()
			local names = lint.linters_by_ft[vim.bo.filetype] or {}
			local path = vim.api.nvim_buf_get_name(0)
			if path:match("%.github/workflows/.*%.ya?ml$") then
				names = vim.list_extend(vim.list_slice(names), { "actionlint" })
			end
			if vim.tbl_contains(names, "selene") and not has_selene_config(path) then
				names = vim.tbl_filter(function(name)
					return name ~= "selene"
				end, names)
			end
			return names
		end

		-- BufEnter fired on every window switch and re-ran every linter as a
		-- subprocess; write + leaving insert is enough.
		vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
			group = vim.api.nvim_create_augroup("lint", { clear = true }),
			callback = function()
				local names = linters_for_buf()
				if #names > 0 then
					lint.try_lint(names)
				end
			end,
		})

		vim.api.nvim_create_user_command("LintInfo", function()
			local names = linters_for_buf()
			if #names == 0 then
				vim.notify("No linters configured for filetype: " .. vim.bo.filetype)
			else
				vim.notify("Active linters for [" .. vim.bo.filetype .. "]: " .. table.concat(names, ", "))
			end
		end, {})
	end,
}

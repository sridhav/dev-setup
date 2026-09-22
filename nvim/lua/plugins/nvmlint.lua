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
			sh = { "shellcheck" },
			bash = { "shellcheck" },
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
		}

		-- GitHub workflow files get the compound filetype `yaml.github`, not
		-- `githubaction`, and nvim-lint resolves that to the `yaml` entry above.
		-- Match them by path instead so actionlint actually runs.
		local function linters_for_buf()
			local names = lint.linters_by_ft[vim.bo.filetype] or {}
			local path = vim.api.nvim_buf_get_name(0)
			if path:match("%.github/workflows/.*%.ya?ml$") then
				names = vim.list_extend(vim.list_slice(names), { "actionlint" })
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

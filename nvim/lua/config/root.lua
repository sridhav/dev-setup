-- The project root for the current buffer, so pickers search the whole project
-- even when Neovim was started in a subdirectory:
--   1. the deepest root of an attached LSP server that contains the file
--   2. else the nearest directory with .git
--   3. else the working directory
local M = {}

function M.get()
	local buf = vim.api.nvim_get_current_buf()
	local path = vim.api.nvim_buf_get_name(buf)
	if path == "" or vim.bo[buf].buftype ~= "" then
		return vim.uv.cwd()
	end
	path = vim.fs.normalize(path)

	local best
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
		local root = client.root_dir and vim.fs.normalize(client.root_dir)
		if root and vim.startswith(path, root .. "/") and (not best or #root > #best) then
			best = root
		end
	end
	return best or vim.fs.root(buf, ".git") or vim.uv.cwd()
end

return M

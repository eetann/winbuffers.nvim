local M = {}

local function set_winbar()
	local buffers = vim.fn.getbufinfo({ buflisted = 1 })
	for _, buffer in ipairs(buffers) do
		local winid = vim.fn.bufwinid(buffer.bufnr)
		if winid ~= -1 then
			vim.wo[winid].winbar = buffer.name
		end
	end
end

local augroup = "winbuffers"
vim.api.nvim_create_augroup(augroup, {})

vim.api.nvim_create_autocmd({ "BufWinEnter", "BufFilePost", "BufWritePost", "DirChanged" }, {
	group = augroup,
	callback = set_winbar,
})

return M

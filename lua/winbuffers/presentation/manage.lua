local Winbar = require("winbuffers.domain.winbar")

---@class autocmd_callback_args
---@field id number
---@field event string
---@field group number?
---@field match string
---@field buf number
---@field file string
---@field data any

local M = {}

---@type {[integer]: Winbuffers.Winbar}
local winbar_table = {}

local augroup = "winbuffers"
vim.api.nvim_create_augroup(augroup, {})

vim.api.nvim_create_autocmd({ "VimEnter", "WinNew", "BufWinEnter" }, {
	group = augroup,
	---@param args autocmd_callback_args
	callback = function(args)
		local winid = vim.api.nvim_get_current_win()
		local winbar = winbar_table[winid]
		local buf = args.buf
		if winbar then
		else
			winbar = Winbar:new(winid)
			winbar_table[winid] = winbar
		end
		winbar:add_buffer(buf)
	end,
})

return M

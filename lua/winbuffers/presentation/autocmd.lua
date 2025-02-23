local WinbarManager = require("winbuffers.domain.winbar_manager")

---@class autocmd_callback_args
---@field id number
---@field event string
---@field group number?
---@field match string
---@field buf number
---@field file string
---@field data any

local M = {}

local manager = WinbarManager:new()

local augroup = "winbuffers"
vim.api.nvim_create_augroup(augroup, {})

vim.api.nvim_create_autocmd({ "BufAdd" }, {
	group = augroup,
	---@param args autocmd_callback_args
	callback = function(args)
		manager:attach_buffer(args.buf)
	end,
})

vim.api.nvim_create_autocmd({ "BufDelete" }, {
	group = augroup,
	---@param args autocmd_callback_args
	callback = function(args)
		manager:detach_buffer(args.buf)
	end,
})

vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
	group = augroup,
	callback = function()
		local current_winid = vim.api.nvim_get_current_win()
		manager:update(current_winid)
	end,
})

return M

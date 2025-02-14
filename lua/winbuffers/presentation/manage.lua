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

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
	group = augroup,
	---@param args autocmd_callback_args
	callback = function(args)
		manager:attach_buffer(args.buf)
	end,
})

return M

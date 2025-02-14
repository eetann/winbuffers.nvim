local Winbar = require("winbuffers.domain.winbar")

---@class Winbuffers.WinbarManager
---@field winbar_table { [integer]: Winbuffers.Winbar }
local WinbarManager = {}
WinbarManager.__index = WinbarManager

function WinbarManager:new()
	return setmetatable({ winbar_table = {} }, WinbarManager)
end

---attach buffer
---@param bufnr integer
function WinbarManager:attach_buffer(bufnr)
	local winid = vim.api.nvim_get_current_win()
	local winbar = self.winbar_table[winid]
	if winbar == nil then
		winbar = Winbar:new(winid)
		self.winbar_table[winid] = winbar
	end
	winbar:add_buffer(bufnr)
end

return WinbarManager

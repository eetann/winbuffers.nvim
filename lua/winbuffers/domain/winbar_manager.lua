local Winbar = require("winbuffers.domain.winbar")

---@class Winbuffers.WinbarManager
---@field winbar_table { [integer]: Winbuffers.Winbar }
---@field unique_buffer_names { [string]: integer } key is filename, value is bufnr
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
	self:update(winbar)
end

---create text to display winbar
---@param winbar Winbuffers.Winbar
function WinbarManager:create_text(winbar)
	local text = ""
	for _, key in ipairs(winbar:get_sorted_keys()) do
		local bufinfo = vim.fn.getbufinfo(winbar.buffers[key].bufnr)[1]
		text = text .. vim.fn.fnamemodify(bufinfo.name, ":t") .. " | "
	end
	return text
end

---@param winbar Winbuffers.Winbar
function WinbarManager:update(winbar)
	local text = self:create_text(winbar)
	winbar:set_winbar(text)
end

return WinbarManager

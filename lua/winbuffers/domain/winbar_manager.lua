local Winbar = require("winbuffers.domain.winbar")
local UniqueNameManager = require("winbuffers.domain.unique_name_manager")

---@class Winbuffers.WinbarManager
---@field winbar_table { [integer]: Winbuffers.Winbar }
---@field unique_name_manager UniqueNameManager
local WinbarManager = {}
WinbarManager.__index = WinbarManager

function WinbarManager:new()
	return setmetatable({ winbar_table = {}, unique_name_manager = UniqueNameManager:new() }, WinbarManager)
end

---create text to display winbar
---@param winbar Winbuffers.Winbar
function WinbarManager:create_text(winbar)
	local text = ""
	local sorted_bufnrs = winbar:get_sorted_bufnrs()
	for _, key in ipairs(sorted_bufnrs) do
		local bufinfo = vim.fn.getbufinfo(winbar.buffers[key].bufnr)[1]
		local filename = vim.fn.fnamemodify(bufinfo.name, ":t")
		local unique_name = self.unique_name_manager:get_unique_name(bufinfo.bufnr, filename)
		-- TODO: ここでハイライトなど
		text = text .. unique_name .. " | "
	end
	return text
end

function WinbarManager:update()
	for _, winbar in pairs(self.winbar_table) do
		local text = self:create_text(winbar)
		winbar:set_winbar(text)
	end
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
	local bufinfo = vim.fn.getbufinfo(bufnr)[1]
	self.unique_name_manager:add_to_unique_list(bufnr, bufinfo.name)

	self:update()
end

---detach buffer
---@param bufnr integer
function WinbarManager:detach_buffer(bufnr)
	local delete_winids = {}
	for winid, winbar in pairs(self.winbar_table) do
		winbar:delete_buffer(bufnr)
		if winbar:get_buffer_length() == 0 then
			table.insert(delete_winids, winid)
		end
	end
	for _, winid in pairs(delete_winids) do
		self.winbar_table[winid] = nil
	end

	local bufinfo = vim.fn.getbufinfo(bufnr)[1]
	self.unique_name_manager:delete_from_unique_list(bufnr, bufinfo.name)

	self:update()
end

return WinbarManager

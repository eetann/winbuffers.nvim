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
---@param current_winid integer
---@param winbar Winbuffers.Winbar
function WinbarManager:create_text(current_winid, winbar)
	local is_focus = winbar.winid == current_winid
	local text = ""
	local sorted_bufnrs = winbar:get_sorted_bufnrs()
	local current_bufnr = winbar:get_current_bufnr()
	for _, key in ipairs(sorted_bufnrs) do
		local bufinfo = vim.fn.getbufinfo(winbar.buffers[key].bufnr)[1]
		local filename = vim.fn.fnamemodify(bufinfo.name, ":t")
		local unique_name = self.unique_name_manager:get_unique_name(bufinfo.bufnr, filename)
		local result = unique_name
		if current_bufnr == bufinfo.bufnr then
			-- TODO: winbarでフォーカスされているバッファならハイライト
			result = result .. "!"
		end
		if is_focus then
			result = result .. "!!"
		end
		text = text .. result .. " | "
	end
	if text == nil then
		return ""
	end
	return text
end

function WinbarManager:update(current_winid)
	for _, winbar in pairs(self.winbar_table) do
		if vim.api.nvim_win_is_valid(winbar.winid) then
			local text = self:create_text(current_winid, winbar)
			winbar:set_winbar(text)
		end
	end
end

---attach buffer
---@param bufnr integer
function WinbarManager:attach_buffer(bufnr)
	local current_winid = vim.api.nvim_get_current_win()
	local winbar = self.winbar_table[current_winid]
	if winbar == nil then
		winbar = Winbar:new(current_winid)
		self.winbar_table[current_winid] = winbar
	end
	winbar:add_buffer(bufnr)
	local bufinfo = vim.fn.getbufinfo(bufnr)[1]
	self.unique_name_manager:add_to_unique_list(bufnr, bufinfo.name)

	self:update(current_winid)
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

	local current_winid = vim.api.nvim_get_current_win()
	self:update(current_winid)
end

return WinbarManager

local Winbar = require("winbuffers.domain.winbar")

local sep = vim.fn.has("win32") == 1 and "\\" or "/"

---@alias filename string
---@alias fullpath string
---@alias bufnr string
---@alias fullpath_dict { [bufnr]: fullpath, buffer_name: string }
---@alias unique_buffer_names { [filename]: fullpath_dict }

---@class Winbuffers.WinbarManager
---@field winbar_table { [integer]: Winbuffers.Winbar }
---@field unique_buffer_names unique_buffer_names
local WinbarManager = {}
WinbarManager.__index = WinbarManager

function WinbarManager:new()
	return setmetatable({ winbar_table = {}, unique_buffer_names = {} }, WinbarManager)
end

---@param bufnr integer
function WinbarManager:get_unique_name(bufnr)
	local bufinfo = vim.fn.getbufinfo(bufnr)[1]
	local filename = vim.fn.fnamemodify(bufinfo.name, ":t")
	local bufnr_list = self.unique_buffer_names[filename]
	if #bufnr_list[filename] == 1 then
		return filename
	end
	-- TODO: ユニークにして返す
	return filename
end

---create text to display winbar
---@param winbar Winbuffers.Winbar
function WinbarManager:create_text(winbar)
	local text = ""
	local sorted_bufnrs = winbar:get_sorted_bufnrs()
	for _, key in ipairs(sorted_bufnrs) do
		text = text .. self:get_unique_name(winbar.buffers[key].bufnr) .. " | "
	end
	return text
end

---@param winbar Winbuffers.Winbar
function WinbarManager:update(winbar)
	local text = self:create_text(winbar)
	winbar:set_winbar(text)
end

---@param bufnr integer
function WinbarManager:add_to_unique_list(bufnr)
	local bufinfo = vim.fn.getbufinfo(bufnr)[1]
	local filename = vim.fn.fnamemodify(bufinfo.name, ":t")
	local bufnr_list = self.unique_buffer_names[filename]
	if bufnr_list == nil then
		self.unique_buffer_names[filename] = {}
	end
	self.unique_buffer_names[filename][bufnr] = bufinfo.name
	-- TODO: ここで重複ケースの場合にファイル名を書いておく
end

-- 情報を集める
-- 重複があればパスを書き換える

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
	self:add_to_unique_list(bufnr)

	self:update(winbar)
end

return WinbarManager

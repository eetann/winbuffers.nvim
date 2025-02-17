local utils = require("winbuffers.domain.utils")
local Winbar = require("winbuffers.domain.winbar")
local UniqueNameManager = require("winbuffers.domain.unique_name_manager")

---@class Winbuffers.WinbarManager
---@field winbar_table { [integer]: Winbuffers.Winbar }
---@field unique_name_manager UniqueNameManager
local WinbarManager = {}
WinbarManager.__index = WinbarManager

function WinbarManager:new()
	return setmetatable({ winbar_table = {}, unique_name_manager = {} }, WinbarManager)
end

---@param bufnr integer
---@return string
function WinbarManager:get_unique_name(bufnr)
	local bufinfo = vim.fn.getbufinfo(bufnr)[1]
	local filename = vim.fn.fnamemodify(bufinfo.name, ":t")
	local bufnr_list = self.unique_name_manager[filename]
	if bufnr_list[bufinfo.bufnr] == nil then
		return ""
	end
	return bufnr_list[bufinfo.bufnr].buffer_name
end

---create text to display winbar
---@param winbar Winbuffers.Winbar
function WinbarManager:create_text(winbar)
	local text = ""
	local sorted_bufnrs = winbar:get_sorted_bufnrs()
	for _, key in ipairs(sorted_bufnrs) do
		local result = self:get_unique_name(winbar.buffers[key].bufnr)
		text = text .. result .. " | "
	end
	return text
end

function WinbarManager:update()
	for _, winbar in pairs(self.winbar_table) do
		local text = self:create_text(winbar)
		winbar:set_winbar(text)
	end
end

---get path with depth specified
---@param path_segment path_segment
---@param depth integer
---@return string
function WinbarManager:get_depth_path(path_segment, depth)
	local length = #path_segment
	local start = length - depth -- 0 based index because vim function
	if start < 0 then
		start = 0
	end
	return table.concat(vim.fn.slice(path_segment, start, length), utils.sep)
end

--- make paths unique
---@param buffer_name_maps { [bufnr]: buffer_name_map }
function WinbarManager:make_path_unique(buffer_name_maps)
	if vim.fn.len(vim.fn.filter(buffer_name_maps, "v:val isnot v:null")) == 1 then
		for _, buffer_name_map in pairs(buffer_name_maps) do
			buffer_name_map.buffer_name = buffer_name_map.path_segment[#buffer_name_map.path_segment]
		end
		return
	end
	local is_all_same_segument = false
	local depth = 1
	while not is_all_same_segument do
		is_all_same_segument = true
		depth = depth + 1
		---@type true|string|nil
		local first_segment = true
		for _, buffer_name_map in pairs(buffer_name_maps) do
			local start = #buffer_name_map.path_segment - (depth - 1)
			local segment = buffer_name_map.path_segment[start]
			if first_segment == true then
				first_segment = segment
			elseif first_segment ~= segment then
				is_all_same_segument = false
				break
			end
		end
	end
	depth = depth - 1
	for bufnr, buffer_name_map in pairs(buffer_name_maps) do
		buffer_name_maps[bufnr]["buffer_name"] = self:get_depth_path(buffer_name_map.path_segment, depth)
	end
end

---@param bufnr integer
---@param fullpath string
function WinbarManager:add_to_unique_list(bufnr, fullpath)
	local filename = vim.fn.fnamemodify(fullpath, ":t")
	local buffer_name_maps = self.unique_buffer_names[filename]
	if buffer_name_maps == nil then
		self.unique_buffer_names[filename] = {
			[bufnr] = {
				path_segment = vim.split(fullpath, utils.sep),
				buffer_name = filename,
			},
		}
	else
		self.unique_buffer_names[filename][bufnr] = { path_segment = vim.split(fullpath, utils.sep), buffer_name = "" }
		self:make_path_unique(self.unique_buffer_names[filename])
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
	self:add_to_unique_list(bufnr, bufinfo.name)

	self:update()
end

---@param bufnr integer
---@param fullpath string
function WinbarManager:delete_from_unique_list(bufnr, fullpath)
	local filename = vim.fn.fnamemodify(fullpath, ":t")
	local buffer_name_maps = self.unique_buffer_names[filename]
	if buffer_name_maps == nil then
		return
	end
	self.unique_buffer_names[filename][bufnr] = nil
	self:make_path_unique(self.unique_buffer_names[filename])
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
	self:delete_from_unique_list(bufnr, bufinfo.name)

	self:update()
end

return WinbarManager

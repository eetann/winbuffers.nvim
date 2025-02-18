local utils = require("winbuffers.domain.utils")

---@alias path_segment string[]
---@alias display_name_fields { path_segment: path_segment, display_name: string }
---@alias display_name_records table<bufnr, display_name_fields>
---@alias display_name_records_dict table<filename, display_name_records>

---@class UniqueNameManager
---@field records_dict display_name_records_dict
local UniqueNameManager = {}
UniqueNameManager.__index = UniqueNameManager

function UniqueNameManager:new()
	return setmetatable({ records_dict = {} }, UniqueNameManager)
end

---@param path_segment path_segment
---@param depth integer
---@return string
function UniqueNameManager:get_depth_path(path_segment, depth)
	local length = #path_segment
	local start = length - depth
	if start < 0 then
		start = 0
	end
	return table.concat(vim.fn.slice(path_segment, start, length), utils.sep)
end

---make 'display name' unique
---@param records table<bufnr, display_name_fields>
function UniqueNameManager:make_path_unique(records)
	if vim.fn.len(vim.fn.filter(records, "v:val isnot v:null")) == 1 then
		for _, fields in pairs(records) do
			fields.display_name = fields.path_segment[#fields.path_segment]
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
		for _, fields in pairs(records) do
			local start = #fields.path_segment - (depth - 1)
			local segment = fields.path_segment[start]
			if first_segment == true then
				first_segment = segment
			elseif first_segment ~= segment then
				is_all_same_segument = false
				break
			end
		end
	end

	depth = depth - 1
	for bufnr, fields in pairs(records) do
		records[bufnr]["display_name"] = self:get_depth_path(fields.path_segment, depth)
	end
end

---@param bufnr integer
---@param fullpath string
function UniqueNameManager:add_to_unique_list(bufnr, fullpath)
	local filename = vim.fn.fnamemodify(fullpath, ":t")
	local records = self.records_dict[filename]
	if records == nil then
		self.records_dict[filename] = {
			[bufnr] = {
				path_segment = vim.split(fullpath, utils.sep),
				display_name = filename,
			},
		}
	else
		records[bufnr] = { path_segment = vim.split(fullpath, utils.sep), display_name = "" }
		self:make_path_unique(records)
	end
end

---@param bufnr integer
---@param fullpath string
function UniqueNameManager:delete_from_unique_list(bufnr, fullpath)
	local filename = vim.fn.fnamemodify(fullpath, ":t")
	local records = self.records_dict[filename]
	if records == nil then
		return
	end
	records[bufnr] = nil
	self:make_path_unique(records)
end

---@param bufnr integer
---@param filename string
---@return string
function UniqueNameManager:get_unique_name(bufnr, filename)
	local records = self.records_dict[filename]
	if records[bufnr] == nil then
		return ""
	end
	return records[bufnr].display_name
end

return UniqueNameManager

---@class Winbuffers.Winbar
---@field winid integer
---@field buffers { [string]: {bufnr: integer, added: integer} }
local Winbar = {}
Winbar.__index = Winbar

---@param winid integer
---@return Winbuffers.Winbar
function Winbar:new(winid)
	return setmetatable({ winid = winid, buffers = {} }, Winbar)
end

function Winbar:get_sorted_bufnrs()
	local sorted_keys = {}
	local i = 1
	for k, _ in pairs(self.buffers) do
		sorted_keys[i] = k
		i = i + 1
	end
	table.sort(sorted_keys, function(a, b)
		return self.buffers[a].added < self.buffers[b].added
	end)
	return sorted_keys
end

---@param text string
function Winbar:set_winbar(text)
	vim.wo[self.winid].winbar = text
end

---@param bufnr integer|nil
function Winbar:add_buffer(bufnr)
	if bufnr == nil or self.buffers[tostring(bufnr)] ~= nil then
		do
			return
		end
	end
	self.buffers[tostring(bufnr)] = { bufnr = bufnr, added = os.time() }
end

---@param delete_bufnr integer
function Winbar:delete_buffer(delete_bufnr)
	self.buffers[tostring(delete_bufnr)] = nil
end

function Winbar:get_buffer_length()
	return vim.fn.len(self.buffers)
end

---return getwininfo
---@return vim.fn.getwininfo.ret.item
function Winbar:get_info()
	return vim.fn.getwininfo(self.winid)[1]
end

function Winbar:get_current_bufnr()
	local wininfo = self:get_info()
	if wininfo then
		return wininfo.bufnr
	end
	return nil
end

return Winbar

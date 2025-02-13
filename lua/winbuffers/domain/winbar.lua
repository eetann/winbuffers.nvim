---@class Winbuffers.Winbar
---@field winid integer
---@field buffers integer[]
local Winbar = {}
Winbar.__index = Winbar

---create winbar
---@param winid integer
---@return Winbuffers.Winbar
function Winbar:new(winid)
	return setmetatable({ winid = winid, buffers = {} }, Winbar)
end

---create text for winbar
---@return string
function Winbar:create_text()
	local text = ""
	for _, bufnr in ipairs(self.buffers) do
		local buf = vim.fn.getbufinfo(bufnr)[1]
		text = text .. vim.fn.fnamemodify(buf.name, ":p") .. " "
	end
	return text
end

function Winbar:set_winbar()
	vim.wo[self.winid].winbar = self:create_text()
end

---@param bufnr integer|nil
function Winbar:add_buffer(bufnr)
	if bufnr == nil then
		do
			return
		end
	end
	-- TODO: 重複を避けたいので、buffersは連想配列にする
	table.insert(self.buffers, bufnr)
	self:set_winbar()
end

---@param delete_bufnr integer
function Winbar:delete_buffer(delete_bufnr)
	for i, bufnr in ipairs(self.buffers) do
		if bufnr == delete_bufnr then
			table.remove(self.buffers, i)
		end
	end
	self:set_winbar()
end

return Winbar

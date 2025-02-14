---@class Winbuffers.Winbar
---@field winid integer
---@field buffers { [string]: integer }
local Winbar = {}
Winbar.__index = Winbar

---@param winid integer
---@return Winbuffers.Winbar
function Winbar:new(winid)
	return setmetatable({ winid = winid, buffers = {} }, Winbar)
end

-- TODO: これは他のWinbarも考慮しなきゃなのでdomainサービスへ
---create text for winbar
---@return string
function Winbar:create_text()
	local text = ""
	for _, bufnr in pairs(self.buffers) do
		local buf = vim.fn.getbufinfo(bufnr)[1]
		text = text .. vim.fn.fnamemodify(buf.name, ":t") .. " | "
	end
	return text
end

function Winbar:set_winbar()
	vim.wo[self.winid].winbar = self:create_text()
end

---@param bufnr integer|nil
function Winbar:add_buffer(bufnr)
	if bufnr == nil or self.buffers[tostring(bufnr)] ~= nil then
		do
			return
		end
	end
	self.buffers[tostring(bufnr)] = bufnr
	self:set_winbar()
end

---@param delete_bufnr integer
function Winbar:delete_buffer(delete_bufnr)
	for key, bufnr in pairs(self.buffers) do
		if bufnr == delete_bufnr then
			self.buffers[key] = nil
		end
	end
	self:set_winbar()
end

return Winbar

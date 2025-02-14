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

function Winbar:get_sorted_keys()
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

-- TODO: これは他のWinbarも考慮しなきゃなのでdomainサービスへ
---create text for winbar
---@return string
function Winbar:create_text()
	local text = ""
	for _, key in ipairs(self:get_sorted_keys()) do
		-- text = text .. key
		local bufinfo = vim.fn.getbufinfo(self.buffers[key].bufnr)[1]
		text = text .. vim.fn.fnamemodify(bufinfo.name, ":t") .. " | "
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
	self.buffers[tostring(bufnr)] = { bufnr = bufnr, added = os.time() }
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

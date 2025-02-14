local MiniDoc = require("mini.doc")
local hooks = vim.deepcopy(MiniDoc.default_hooks)

hooks.write_pre = function(lines)
	-- Remove first two lines with `======` and `------` delimiters to comply
	-- with `:h local-additions` template
	table.remove(lines, 1)
	table.remove(lines, 1)
	return lines
end
MiniDoc.generate({
	"lua/winbuffers/init.lua",
	"lua/winbuffers/presentation/command.lua",
}, "doc/winbuffers.txt", { hooks = hooks })

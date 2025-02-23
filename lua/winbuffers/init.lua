--- *winbuffers* Displays buffers as tabs per window.
---
--- ==============================================================================
--- Table of Contents                                  *winbuffers-table-of-contents*
---@toc
---@text

local WinBuffers = require("winbuffers.presentation.api")

WinBuffers.config = {
	word = "Hello!",
}

---@tag winbuffers-setup
---@toc_entry Setup
---@text
--- No setup argument is required.
---
WinBuffers.setup = function(args)
	WinBuffers.config = vim.tbl_deep_extend("force", WinBuffers.config, args or {})
	require("winbuffers.presentation.autocmd").set_autocmds()
	require("winbuffers.presentation.command")
end

return WinBuffers

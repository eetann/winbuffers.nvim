local Winbar = require("winbuffers.domain.winbar")
local Helpers = dofile("tests/helpers.lua")
local child = Helpers.new_child_neovim()
local expect, eq = Helpers.expect, Helpers.expect.equality

local T = MiniTest.new_set({
	hooks = {
		pre_case = function()
			child.setup()
			child.load()
		end,
		post_once = child.stop,
	},
})

T["is_no_buffers"] = function()
	local winbar = Winbar:new(1)
	winbar:add_buffer(1)
	winbar:add_buffer(2)
	winbar:add_buffer(3)
	winbar:delete_buffer(2)
	eq(winbar:get_buffer_length(), 2)
	winbar:delete_buffer(1)
	eq(winbar:get_buffer_length(), 1)
end

return T

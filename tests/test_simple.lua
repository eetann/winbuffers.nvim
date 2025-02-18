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

T["works with split command"] = function()
	-- | 1 |
	local win1 = child.api.nvim_get_current_win()
	child.cmd("edit src/foo.lua")
	expect.winbar_current_matching(child, "foo.lua!!! | ")

	-- | 2 | 1 |
	-- 2
	child.cmd("vsplit src/bar.lua")
	local win2 = child.api.nvim_get_current_win()
	expect.winbar_current_matching(child, "bar.lua!!! | ")
	expect.winbar_matching(child, win1, "foo.lua! | ")

	-- | 3 |   |
	-- |---| 1 |
	-- | 2 |   |
	-- 3
	child.cmd("split foo/buz/buz.lua")
	expect.winbar_current_matching(child, "buz.lua | ")
	expect.winbar_matching(child, win2, "bar.lua! | ")
end

T["works without split command"] = function()
	-- | 1 |
	child.cmd("edit src/foo/bar.lua")
	expect.winbar_current_matching(child, "bar.lua!!! | ")

	-- | 2 | 1 |
	-- 2
	child.cmd("vsplit")
	child.cmd("edit src/foo2/bar.lua")
	expect.winbar_current_matching(child, "foo2/bar.lua!!! | ")
	-- 1
	child.cmd("wincmd l") -- jump right
	expect.winbar_current_matching(child, "foo/bar.lua!!! | ")
end

T["delete buffer"] = function()
	-- | 1 |
	child.cmd("edit src/foo/bar.lua")

	-- | 2 | 1 |
	-- 2
	child.cmd("vsplit src/foo2/bar.lua")
	child.cmd("bd")
	expect.winbar_current_matching(child, "bar.lua!!! | ")
end

return T

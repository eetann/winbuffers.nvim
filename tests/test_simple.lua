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

T["add_to_unique_list"] = function()
	-- TODO: 書く
end

T["works"] = function()
	-- | 1 |
	child.cmd("edit src/foo.lua")
	-- expect.winbar_current_matching(child, "foo.lua | ")

	-- | 2 | 1 |
	-- 2
	child.cmd("vsplit src/bar.lua")
	expect.winbar_current_matching(child, "bar.lua | ")
	-- -- 1
	-- child.cmd("wincmd l") -- jump right
	-- expect.winbar_current_matching(child, "foo.lua | ")
	-- -- 2
	-- child.cmd("wincmd h") -- jump left
	--
	-- -- | 3 |   |
	-- -- |---| 1 |
	-- -- | 2 |   |
	-- -- 3
	-- child.cmd("split foo/buz/buz.lua")
	-- expect.winbar_current_matching(child, "buz.lua | ")
	-- child.cmd("wincmd j") -- 2
	-- expect.winbar_current_matching(child, "bar.lua | ")
end

return T

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

T["works"] = function()
	eq(1, #vim.fn.getbufinfo())
	-- | 1 |
	child.cmd("edit src/foo.lua")
	-- expect.winbar_current_matching(child, "foo.lua | ")

	-- | 2 | 1 |
	-- 2
	child.cmd("vsplit")
	vim.uv.sleep(1000)
	child.cmd("edit src/bar.lua")
	expect.winbar_current_matching(child, "foo.lua | bar.lua | ")
	-- 1
	child.cmd("wincmd l") -- jump right
	expect.winbar_current_matching(child, "foo.lua | ")
	-- 2
	child.cmd("wincmd h") -- jump left

	-- | 3 |   |
	-- |---| 1 |
	-- | 2 |   |
	child.cmd("split") -- 3
	vim.uv.sleep(1000)
	expect.winbar_current_matching(child, "bar.lua | ")
	child.cmd("edit foo/buz/buz.lua")
	expect.winbar_current_matching(child, "bar.lua | buz.lua | ")
	child.cmd("wincmd j") -- 1
	expect.winbar_current_matching(child, "foo.lua | bar.lua | ")
end

return T

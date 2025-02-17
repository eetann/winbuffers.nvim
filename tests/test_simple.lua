local WinbarManager = require("winbuffers.domain.winbar_manager")
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
	local manager = WinbarManager:new()
	manager:add_to_unique_list(1, "/home/adam/foo/bar/buz.txt")
	manager:add_to_unique_list(2, "/home/adam/foo/bar/piyo.txt")
	manager:add_to_unique_list(3, "/home/adam/foo/bar2/piyo.txt")
	eq(manager.unique_buffer_names["buz.txt"], {
		[1] = {
			path_segment = { "", "home", "adam", "foo", "bar", "buz.txt" },
			buffer_name = "buz.txt",
		},
	})
	eq(manager.unique_buffer_names["piyo.txt"], {
		[2] = {
			path_segment = { "", "home", "adam", "foo", "bar", "piyo.txt" },
			buffer_name = "bar/piyo.txt",
		},
		[3] = {
			path_segment = { "", "home", "adam", "foo", "bar2", "piyo.txt" },
			buffer_name = "bar2/piyo.txt",
		},
	})
end

T["get_unique_name"] = function()
	local manager = WinbarManager:new()
	manager:add_to_unique_list(1, "/home/adam/foo/bar/buz.txt")
	manager:add_to_unique_list(2, "/home/adam/foo/bar/piyo.txt")
	manager:add_to_unique_list(3, "/home/adam/foo/bar2/piyo.txt")
end

T["works"] = function()
	-- | 1 |
	child.cmd("edit src/foo.lua")
	expect.winbar_current_matching(child, "foo.lua | ")

	-- | 2 | 1 |
	-- 2
	child.cmd("vsplit src/bar.lua")
	expect.winbar_current_matching(child, "bar.lua | ")
	-- 1
	child.cmd("wincmd l") -- jump right
	expect.winbar_current_matching(child, "foo.lua | ")
	-- 2
	child.cmd("wincmd h") -- jump left

	-- | 3 |   |
	-- |---| 1 |
	-- | 2 |   |
	-- 3
	child.cmd("split foo/buz/buz.lua")
	expect.winbar_current_matching(child, "buz.lua | ")
	child.cmd("wincmd j") -- 2
	expect.winbar_current_matching(child, "bar.lua | ")
end

T["works 2"] = function()
	-- | 1 |
	child.cmd("edit src/foo/bar.lua")
	expect.winbar_current_matching(child, "bar.lua | ")

	-- | 2 | 1 |
	-- 2
	child.cmd("vsplit")
	child.cmd("edit src/foo2/bar.lua")
	expect.winbar_current_matching(child, "foo2/bar.lua | ")
	-- 1
	child.cmd("wincmd l") -- jump right
	expect.winbar_current_matching(child, "foo/bar.lua | ")
end

return T

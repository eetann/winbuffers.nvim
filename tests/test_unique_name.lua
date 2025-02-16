local Helpers = dofile("tests/helpers.lua")
local WinbarManager = require("winbuffers.domain.winbar_manager")
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

T["get_depth_path"] = function()
	local path_segment = { "foo", "bar", "buz", "piyo.txt" }
	local path = WinbarManager:get_depth_path(path_segment, 1)
	eq(path, "piyo.txt")
	path = WinbarManager:get_depth_path(path_segment, 3)
	eq(path, "bar/buz/piyo.txt")
	path = WinbarManager:get_depth_path(path_segment, 10)
	eq(path, "foo/bar/buz/piyo.txt")
end

T["make_path_unique 2 files"] = function()
	local buffer_name_maps = {}
	buffer_name_maps[1] = {
		path_segment = { "foo", "bar", "buz", "piyo.txt" },
		buffer_name = "",
	}
	buffer_name_maps[2] = {
		path_segment = { "foo", "bar", "buz2", "piyo.txt" },
		buffer_name = "",
	}
	WinbarManager:make_path_unique(buffer_name_maps)
	eq(buffer_name_maps[1]["buffer_name"], "buz/piyo.txt")
	eq(buffer_name_maps[2]["buffer_name"], "buz2/piyo.txt")
end

T["make_path_unique 3 files"] = function()
	local buffer_name_maps = {}
	buffer_name_maps[1] = {
		path_segment = { "foo", "bar", "buz", "piyo.txt" },
		buffer_name = "",
	}
	buffer_name_maps[2] = {
		path_segment = { "foo", "bar", "buz2", "piyo.txt" },
		buffer_name = "",
	}
	buffer_name_maps[3] = {
		path_segment = { "foo", "bar2", "buz", "piyo.txt" },
		buffer_name = "",
	}
	WinbarManager:make_path_unique(buffer_name_maps)
	eq(buffer_name_maps[1]["buffer_name"], "bar/buz/piyo.txt")
	eq(buffer_name_maps[2]["buffer_name"], "bar/buz2/piyo.txt")
	eq(buffer_name_maps[3]["buffer_name"], "bar2/buz/piyo.txt")
end

T["make_path_unique files of different depths"] = function()
	local buffer_name_maps = {}
	buffer_name_maps[1] = {
		path_segment = { "foo", "bar", "buz", "piyo.txt" },
		buffer_name = "",
	}
	buffer_name_maps[2] = {
		path_segment = { "bar", "buz2", "piyo.txt" },
		buffer_name = "",
	}
	WinbarManager:make_path_unique(buffer_name_maps)
	eq(buffer_name_maps[1]["buffer_name"], "buz/piyo.txt")
	eq(buffer_name_maps[2]["buffer_name"], "buz2/piyo.txt")
end

return T

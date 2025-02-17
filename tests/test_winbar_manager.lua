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
	manager.unique_name_manager:add_to_unique_list(1, "/home/adam/foo/bar/buz.txt")
	manager.unique_name_manager:add_to_unique_list(2, "/home/adam/foo/bar/piyo.txt")
	manager.unique_name_manager:add_to_unique_list(3, "/home/adam/foo/bar2/piyo.txt")
	eq(manager.unique_name_manager.records_dict["buz.txt"], {
		[1] = {
			path_segment = { "", "home", "adam", "foo", "bar", "buz.txt" },
			display_name = "buz.txt",
		},
	})
	eq(manager.unique_name_manager.records_dict["piyo.txt"], {
		[2] = {
			path_segment = { "", "home", "adam", "foo", "bar", "piyo.txt" },
			display_name = "bar/piyo.txt",
		},
		[3] = {
			path_segment = { "", "home", "adam", "foo", "bar2", "piyo.txt" },
			display_name = "bar2/piyo.txt",
		},
	})
end

T["get_unique_name"] = function()
	local manager = WinbarManager:new()
	manager.unique_name_manager:add_to_unique_list(1, "/home/adam/foo/bar/buz.txt")
	manager.unique_name_manager:add_to_unique_list(2, "/home/adam/foo/bar/piyo.txt")
	manager.unique_name_manager:add_to_unique_list(3, "/home/adam/foo/bar2/piyo.txt")
	eq(manager.unique_name_manager.records_dict["buz.txt"][1].display_name, "buz.txt")
	eq(manager.unique_name_manager.records_dict["piyo.txt"][2].display_name, "bar/piyo.txt")
	eq(manager.unique_name_manager.records_dict["piyo.txt"][3].display_name, "bar2/piyo.txt")
end

T["delete_from_unique_list"] = function()
	local manager = WinbarManager:new()
	manager.unique_name_manager:add_to_unique_list(1, "/home/adam/foo/bar/buz.txt")
	manager.unique_name_manager:add_to_unique_list(2, "/home/adam/foo/bar/piyo.txt")
	eq(manager.unique_name_manager.records_dict["piyo.txt"][2].display_name, "piyo.txt")

	manager.unique_name_manager:add_to_unique_list(3, "/home/adam/foo/bar2/piyo.txt")
	eq(manager.unique_name_manager.records_dict["piyo.txt"][2].display_name, "bar/piyo.txt")

	manager.unique_name_manager:delete_from_unique_list(3, "/home/adam/foo/bar2/piyo.txt")
	eq(manager.unique_name_manager.records_dict["buz.txt"][1].display_name, "buz.txt")
	eq(manager.unique_name_manager.records_dict["piyo.txt"][2].display_name, "piyo.txt")
	eq(manager.unique_name_manager.records_dict["piyo.txt"][3], nil)
	eq(vim.fn.len(vim.fn.filter(manager.unique_name_manager.records_dict["piyo.txt"], "v:val isnot v:null")), 1)
end

return T

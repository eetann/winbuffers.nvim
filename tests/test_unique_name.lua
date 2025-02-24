local Helpers = dofile("tests/helpers.lua")
local UniqueNameManager = require("winbuffers.domain.unique_name_manager")
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
  local path = UniqueNameManager:get_depth_path(path_segment, 1)
  eq(path, "piyo.txt")
  path = UniqueNameManager:get_depth_path(path_segment, 3)
  eq(path, "bar/buz/piyo.txt")
  path = UniqueNameManager:get_depth_path(path_segment, 10)
  eq(path, "foo/bar/buz/piyo.txt")
end

T["make_path_unique 2 files"] = function()
  local manager = UniqueNameManager:new()
  manager:add_to_unique_list(1, "foo/bar/buz/piyo.txt")
  manager:add_to_unique_list(2, "foo/bar/buz2/piyo.txt")
  manager:make_path_unique(manager.records_dict["piyo.txt"])
  eq(manager.records_dict["piyo.txt"][1]["display_name"], "buz/piyo.txt")
  eq(manager.records_dict["piyo.txt"][2]["display_name"], "buz2/piyo.txt")
end

T["make_path_unique 3 files"] = function()
  local manager = UniqueNameManager:new()
  manager:add_to_unique_list(1, "foo/bar/buz/piyo.txt")
  manager:add_to_unique_list(2, "foo/bar/buz2/piyo.txt")
  manager:add_to_unique_list(3, "foo/bar2/buz/piyo.txt")
  manager:make_path_unique(manager.records_dict["piyo.txt"])
  eq(manager.records_dict["piyo.txt"][1]["display_name"], "bar/buz/piyo.txt")
  eq(manager.records_dict["piyo.txt"][2]["display_name"], "bar/buz2/piyo.txt")
  eq(manager.records_dict["piyo.txt"][3]["display_name"], "bar2/buz/piyo.txt")
end

T["make_path_unique files of different depths"] = function()
  local manager = UniqueNameManager:new()
  manager:add_to_unique_list(1, "foo/bar/buz/piyo.txt")
  manager:add_to_unique_list(2, "bar/buz2/piyo.txt")
  manager:make_path_unique(manager.records_dict["piyo.txt"])
  eq(manager.records_dict["piyo.txt"][1]["display_name"], "buz/piyo.txt")
  eq(manager.records_dict["piyo.txt"][2]["display_name"], "buz2/piyo.txt")
end

return T

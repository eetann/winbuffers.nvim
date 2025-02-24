local Helpers = {}

Helpers.expect = vim.deepcopy(MiniTest.expect)

Helpers.get_winbar = function(child, winid)
  -- Because it cannot be get correctly by `child.wo[winid].winbar`
  return child.api.nvim_get_option_value("winbar", { win = winid })
end

---If it is a string, return the string as is.
---If it is a table, concat and return string.
---@param expected_value string|string[]
---@return string
local function toStringOrConcat(expected_value)
  if type(expected_value) == "string" then
    return expected_value
  end
  return table.concat(expected_value, "")
end

Helpers.expect.winbar_current_matching = MiniTest.new_expectation(
  "current winbar matching",
  function(child, expected)
    if type(child) == "string" then
      return false
    end
    return child.wo.winbar == toStringOrConcat(expected)
  end,
  function(child, expected)
    if type(child) == "string" then
      return "Specify child as the first argument"
    end
    return string.format(
      "received '%s' is not equal expected '%s'",
      child.wo.winbar,
      toStringOrConcat(expected)
    )
  end
)

Helpers.expect.winbar_matching = MiniTest.new_expectation(
  "winbar matching",
  function(child, winid, expected)
    if type(child) == "string" or type(child) == "number" then
      return false
    end
    return Helpers.get_winbar(child, winid) == toStringOrConcat(expected)
  end,
  function(child, winid, expected)
    if type(child) == "string" or type(child) == "number" then
      return "Specify child as the first argument"
    end
    return string.format(
      "received '%s' is not equal expected '%s'",
      Helpers.get_winbar(child, winid),
      toStringOrConcat(expected)
    )
  end
)

-- ---@type fun(received: any, expected: any)
-- Helpers.expect.toContain = MiniTest.new_expectation("contain value in array", function(received, expected)
-- 	for _, value in pairs(received) do
-- 		if Helpers.expect.equality(value, expected) then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end, function(received, expected)
-- 	return string.format("%s is not contained. array:\n%s", vim.inspect(received), vim.inspect(expected))
-- end)

Helpers.new_child_neovim = function()
  local child = MiniTest.new_child_neovim()

  ---@diagnostic disable-next-line: inject-field
  child.setup = function()
    child.restart({ "-u", "scripts/test/minimal_init.lua" })
    child.bo.readonly = false
  end

  ---@diagnostic disable-next-line: inject-field
  child.load = function(config)
    child.lua("require('winbuffers').setup(...)", { config })
  end

  return child
end

return Helpers

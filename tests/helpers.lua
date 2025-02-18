local Helpers = {}

Helpers.expect = vim.deepcopy(MiniTest.expect)

Helpers.expect.winbar_current_matching = MiniTest.new_expectation("current winbar matching", function(child, expected)
	if type(child) == "string" then
		return false
	end
	return child.wo.winbar == expected
end, function(child, expected)
	if type(child) == "string" then
		return "Specify child as the first argument"
	end
	return string.format("received '%s' is not equal expected '%s'", child.wo.winbar, expected)
end)

Helpers.expect.winbar_matching = MiniTest.new_expectation("winbar matching", function(child, winid, expected)
	if type(child) == "string" or type(child) == "number" then
		return false
	end
	return child.wo[winid].winbar == expected
end, function(child, winid, expected)
	if type(child) == "string" or type(child) == "number" then
		return "Specify child as the first argument"
	end
	return string.format("received '%s' is not equal expected '%s'", child.wo[winid].winbar, expected)
end)

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

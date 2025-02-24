local M = {}

---@type table<string, vim.api.keyset.highlight>
local highlight_dict = {
  FocusWindowTab = { link = "@markup.heading" },
  CurrentBufferTab = { link = "@markup" },
  UnCurrentBufferTab = { link = "@comment" },
}

function M.set_highlights()
  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
      for group_name, value in pairs(highlight_dict) do
        vim.api.nvim_set_hl(0, "WinBuffers" .. group_name, value)
      end
    end,
  })
end

return M

local M = {}

local function get_hl(name)
  ---@type vim.api.keyset.highlight
  return vim.api.nvim_get_hl(0, { name = name, link = false, create = false })
end

---convert decimal format color to (R, G, B)
---15133418 -> 230, 234, 234
---@param decimal integer color
---@return integer? R
---@return integer? G
---@return integer? B
local function decimal_to_rgb(decimal)
  if decimal == nil then
    return nil, nil, nil
  end
  local hex = ("%06x"):format(decimal)
  return tonumber(hex:sub(1, 2), 16),
    tonumber(hex:sub(3, 4), 16),
    tonumber(hex:sub(5), 16)
end

---operate color
---@param num any
---@param percentage any
---@return integer
local function calc(num, percentage)
  return math.min(math.floor(num * percentage), 255)
end

---convert decimal format color to color code
---15133418 -> #E6EAEA
---@param decimal integer
---@param percentage number|nil 0 ~ 1 or nil
---@return string
local function decimal_to_color_code(decimal, percentage)
  local r, g, b = decimal_to_rgb(decimal)
  if not r or not g or not b then
    return "NONE"
  end
  if percentage == nil then
    return ("#%02x%02x%02x"):format(r, g, b)
  end
  r, g, b = calc(r, percentage), calc(g, percentage), calc(b, percentage)
  return ("#%02x%02x%02x"):format(r, g, b)
end

---get and adjust highlight
---@param name string
---@param percentage number|nil
---@param opts vim.api.keyset.highlight
---@return vim.api.keyset.highlight
local function get_adjusted_hl(name, percentage, opts)
  local hl = get_hl(name)
  local fg = decimal_to_color_code(hl.fg, percentage)
  local bg = decimal_to_color_code(hl.bg, percentage)
  return vim.tbl_deep_extend("force", hl, { fg = fg, bg = bg }, opts)
end

---@type table<string, vim.api.keyset.highlight>
local highlight_dict = {
  FocusWindowTab = get_adjusted_hl("StatusLine", nil, { bold = true }),
  CurrentBufferTab = get_adjusted_hl("StatusLineNC", nil, { bold = false }),
  UnCurrentBufferTab = get_adjusted_hl("StatusLineNC", 0.5, { bold = false }),
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

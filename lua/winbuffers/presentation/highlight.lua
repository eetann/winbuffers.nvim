local M = {}

local function get_hl(name)
  return vim.api.nvim_get_hl(0, { name = name, link = false, create = false })
end

-- TODO: もっといい名前にする
---convert decimal format color to RGB
---@param decimal integer color
---@return integer? R
---@return integer? G
---@return integer? B
local function decimal_to_rgb(decimal)
  if decimal == nil then
    return nil, nil, nil
  end
  local hex = ("#%06x"):format(decimal)
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

---TODO: コメントを書く
---@param decimal integer
---@param percentage number 0 ~ 1
---@return string
local function decimal_to_rrggbb(decimal, percentage)
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

local function get_adjusted_hl(name, percentage)
  local hl = get_hl(name)
  local fg = decimal_to_rrggbb(hl.fg, percentage)
  local bg = decimal_to_rrggbb(hl.bg, percentage)
  return vim.tbl_deep_extend("force", hl, { fg = fg, bg = bg })
end

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

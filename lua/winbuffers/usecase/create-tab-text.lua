local ns = "WinBuffers"

---@class Winbuffers.CreateTabText
local CreateTabText = {}

---create text to display as tab
---@param is_focus_window boolean
---@param is_current_buffer boolean
---@param unique_name string display name
---@param bufinfo vim.fn.getbufinfo.ret.item buffer information
function CreateTabText:execute(
  is_focus_window,
  is_current_buffer,
  unique_name,
  bufinfo
)
  local text = ""

  -- TODO: 背景色・前景色を反映する
  -- local ok, devicons = pcall(require, "nvim-web-devicons")
  -- if ok then
  --   local icon, color =
  --     devicons.get_icon(vim.fn.fnamemodify(unique_name, ":t"), nil, {
  --       default = true,
  --     })
  --   if icon ~= nil and color ~= nil then
  --     text = " " .. icon .. " "
  --   end
  -- end

  if is_current_buffer then
    if is_focus_window then
      text = text .. "%#" .. ns .. "FocusWindowTab#"
    else
      text = text .. "%#" .. ns .. "CurrentBufferTab#"
    end
  else
    text = text .. "%#" .. ns .. "UnCurrentBufferTab#"
  end
  return text .. " " .. unique_name .. " %#Normal#"
end

return CreateTabText

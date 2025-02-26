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
  -- TODO: tableにする
  local text = ""
  if is_current_buffer then
    if is_focus_window then
      text = "%#" .. ns .. "FocusWindowTab#"
    else
      text = "%#" .. ns .. "CurrentBufferTab#"
    end
  else
    text = "%#" .. ns .. "UnCurrentBufferTab#"
  end
  return text .. " " .. unique_name .. " %#Normal#"
end

return CreateTabText

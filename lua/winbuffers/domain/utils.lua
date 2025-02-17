local M = {}

M.sep = vim.fn.has("win32") == 1 and "\\" or "/"

---@alias filename string
---@alias bufnr integer

return M

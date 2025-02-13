vim.cmd("colorscheme habamax")
vim.cmd("edit scripts/minimal_init.lua")
vim.cmd("vsplit")
vim.cmd("edit lua/winbuffers/init.lua")
vim.cmd("split")
vim.cmd("edit tests/minimal_init.lua")

vim.keymap.set("n", "s", "<NOP>")

vim.keymap.set("n", "sj", "<C-w>j")
vim.keymap.set("n", "sk", "<C-w>k")
vim.keymap.set("n", "sl", "<C-w>l")
vim.keymap.set("n", "sh", "<C-w>h")
vim.keymap.set("n", "sc", "<C-w>c")

vim.keymap.set("n", "-", "<Cmd>split<CR>")
vim.keymap.set("n", "<Bar>", "<Cmd>vsplit<CR>")
vim.keymap.set("n", "<Bslash>", "<Cmd>vsplit<CR>")

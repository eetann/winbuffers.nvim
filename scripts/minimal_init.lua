local mini_doc_dir = vim.fn.stdpath("data") .. "/lazy/mini.doc"
local is_not_a_directory = vim.fn.isdirectory(mini_doc_dir) == 0
if is_not_a_directory then
	mini_doc_dir = "/tmp/mini.doc"
	is_not_a_directory = vim.fn.isdirectory(mini_doc_dir) == 0
	if is_not_a_directory then
		vim.fn.system({ "git", "clone", "https://github.com/echasnovski/mini.doc", mini_doc_dir })
	end
end
vim.opt.rtp:append(".")
vim.opt.rtp:append(mini_doc_dir)

require("mini.doc").setup()

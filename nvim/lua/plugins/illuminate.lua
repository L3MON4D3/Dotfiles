vim.cmd("hi! link IlluminatedWordText CursorLine")
vim.cmd("hi! link IlluminatedWordRead CursorLine")
vim.cmd("hi! link IlluminatedWordWrite CursorLine")

require("illuminate").configure({
	providers = {"lsp", "treesitter"},
	modes_allowlist = {"n"}
})

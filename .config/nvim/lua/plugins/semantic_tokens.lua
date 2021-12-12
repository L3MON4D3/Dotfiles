require("nvim-semantic-tokens").setup({preset = "default"})

vim.cmd([[
if &filetype == "cpp" || &filetype == "c" || &filetype == "rust"
	augroup semantic_tokens
	autocmd BufEnter,CursorHold,InsertLeave <buffer> lua require 'vim.lsp.semantic_tokens'.refresh()
	augroup END
endif]])

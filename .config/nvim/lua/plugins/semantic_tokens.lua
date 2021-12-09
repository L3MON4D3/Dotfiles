require("nvim-semantic-tokens").setup({preset = "default"})

vim.cmd([[
if &filetype == "cpp" || &filetype == "c" || &filetype == "rust"
	autocmd BufEnter,CursorHold,InsertLeave <buffer> lua require 'vim.lsp.buf'.semantic_tokens_full()
endif]])

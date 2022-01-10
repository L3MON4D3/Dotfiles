require("nvim-semantic-tokens").setup({preset = "default"})

vim.cmd([[
	augroup setup_semantic_tokens
	au!
	autocmd BufWinEnter,Filetype * lua if string.find("cpp;c;rust", vim.bo.filetype) then require("plugins.semantic_tokens.buf_setup")() end
	augroup END
]])

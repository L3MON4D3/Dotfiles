return function()
	vim.schedule(function()
		vim.cmd([[
			augroup semantic_tokens
			au!
			autocmd BufEnter,CursorHold,InsertLeave,TextChanged <buffer> lua require'vim.lsp.buf'.semantic_tokens_full()
			augroup END
		]])
		require'vim.lsp.buf'.semantic_tokens_full()
	end)
end

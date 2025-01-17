_G.expand_func = ls.snip_expand

ls.snip_expand = function(snip, expand_params)
	_G.expand_snip = snip
	_G.expand_opts = expand_params
	vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>repeatable-snip-expand', true, true, true), '')
end

_G.repeatable_expand = function()
	print("here!!!")
	-- actually expands the snippet.
	_G.expand_func(_G.expand_snip, _G.expand_opts)

	-- prevent clearing text on repeated calls.
	_G.expand_opts.clear_region = nil
	_G.expand_opts.pos = nil

	vim.cmd[[silent! call repeat#set("\<Plug>repeatable-snip-expand", -1)]]
end

vim.cmd[[
	noremap <silent> <Plug>repeatable-snip-expand <cmd>lua _G.repeatable_expand()<Cr>
	noremap! <silent> <Plug>repeatable-snip-expand <cmd>lua _G.repeatable_expand()<Cr>
]]

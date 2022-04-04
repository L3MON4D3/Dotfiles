local types = require("luasnip.util.types")
ls = require("luasnip")

--vim.cmd("hi link LuasnipSnippetActive GruvboxRed")
ls.config.setup({
	history = true,
	update_events = "InsertLeave",
	enable_autosnippets = true,
	region_check_events = "CursorHold,InsertLeave",
	delete_check_events = "TextChanged,InsertEnter",
	store_selection_keys = "<Tab>",
	ext_opts = {
		[types.choiceNode] = {
			active = {
				virt_text = {{"●", "GruvboxOrange"}},
				priority = 0
			},
		},
	},
	ft_func = require("luasnip.extras.filetype_functions").from_pos_or_filetype,
	snip_env = {
		s = ls.s,
		sn = ls.sn,
		t = ls.t,
		i = ls.i,
		f = function(func, argnodes, ...)
			return ls.f(function(args, imm_parent, user_args)
				return func(args, imm_parent.snippet, user_args)
			end, argnodes, ...)
		end,
		-- override to enable restore_cursor.
		c = function(pos, nodes, opts)
			opts = opts or {}
			opts.restore_cursor = true
			return ls.c(pos, nodes, opts)
		end,
		d = function(pos, func, argnodes, ...)
			return ls.d(pos, function(args, imm_parent, old_state, ...)
				return func(args, imm_parent.snippet, old_state, ...)
			end, argnodes, ...)
		end,
		isn = require("luasnip.nodes.snippet").ISN,
		l = require'luasnip.extras'.lambda,
		dl = require'luasnip.extras'.dynamic_lambda,
		rep = require'luasnip.extras'.rep,
		r = ls.restore_node,
		p = require("luasnip.extras").partial,
		types = require("luasnip.util.types"),
		events = require("luasnip.util.events"),
		util = require("luasnip.util.util"),
		fmt = require("luasnip.extras.fmt").fmt,
		fmta = require("luasnip.extras.fmt").fmta,
		ls = ls,
		ins_generate = function(nodes)
			return setmetatable(nodes or {}, {
			__index = function(table, key)
				local indx = tonumber(key)
				if indx then
					local val = ls.i(indx)
					rawset(table, key, val)
					return val
				end
			end})
		end,
		parse = ls.parser.parse_snippet,
		n = require("luasnip.extras").nonempty,
		m = require("luasnip.extras").match,
		ai = require("luasnip.nodes.absolute_indexer")
	}
})

ls.filetype_extend("latex", {"tex"})

-- local function load_snippet_file(filename)
-- 	-- 420 = 0644
-- 	local fd = vim.loop.fs_open(filename, "r", 420)
--
-- 	if not fd then
-- 		return nil
-- 	end
--
-- 	local size = vim.loop.fs_fstat(fd).size
-- 	local func_string = vim.loop.fs_read(fd, size)
-- 	-- don't use require, we know where the file resides.
-- 	func_string = 'dofile("/home/simon/.config/nvim/lua/plugins/luasnip/helpers.lua").setup_snip_env() ' .. func_string
-- 	return loadstring(func_string)()
-- end

-- ls.snippets = setmetatable({}, {
-- 	__index = function(t, k)
-- 		-- absolute path!!!
-- 		-- adds snip_env to the file before generating the function.
-- 		local snippets = load_snippet_file("/home/simon/.config/nvim/lua/snippets/"..k..".lua")
-- 		-- set to empty table if no snippets found, prevents loading the file again on the next expand.
-- 		t[k] = snippets or {}
-- 		return t[k]
-- 	end
-- })



vim.cmd [[command! LuaSnipEdit :lua require("luasnip.loaders.from_lua").edit_snippet_files()]]
vim.cmd [[
	inoremap <silent> <C-K> <cmd>lua ls.expand()<Cr>
	inoremap <silent> <C-L> <cmd>lua ls.jump(1)<Cr>
	inoremap <silent> <C-J> <cmd>lua ls.jump(-1)<Cr>

	snoremap <silent> <C-L> <cmd>lua ls.jump(1)<Cr>
	snoremap <silent> <C-J> <cmd>lua ls.jump(-1)<Cr>

	imap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : ''
	smap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : ''

	imap <silent><expr> <C-T> luasnip#choice_active() ? '<Plug>luasnip-prev-choice' : ''
	smap <silent><expr> <C-T> luasnip#choice_active() ? '<Plug>luasnip-prev-choice' : ''
]]
vim.cmd [[
augroup snippets_clear
au!
au BufWritePost *lua/snippets/*.lua :execute 'lua require("luasnip").snippets[string.match("'.expand("<afile>").'", "/([^/]*)%.lua$")] = nil'
augroup END
]]

require("luasnip.loaders.from_lua").load()

require("plugins.luasnip.external_update_dynamic_node")
-- require("luasnip/loaders/from_vscode").load()
-- require("plugins.luasnip.repeat_integration")

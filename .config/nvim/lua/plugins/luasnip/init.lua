local types = require("luasnip.util.types")

ls = require("luasnip")

--vim.cmd("hi link LuasnipSnippetActive GruvboxRed")
ls.config.setup({
	history = true,
	loaders_store_source = true,
	update_events = {"InsertLeave"},
	enable_autosnippets = true,
	region_check_events = {"CursorHold", "InsertLeave"},
	delete_check_events = "TextChanged, InsertEnter",
	store_selection_keys = "<Tab>",
	ext_opts = {
		[types.choiceNode] = {
			active = {
				virt_text = {{"●", "GruvboxOrange"}},
				priority = 0
			},
		},
	},
	ft_func = function()
		local fts = require("luasnip.extras.filetype_functions").from_pos_or_filetype()
		-- should be possible to extend `all`-filetype.
		table.insert(fts, "all")
		local effective_fts = {}

		local buflocal_extend = Config(0).luasnip_ft_extend
		if buflocal_extend then
			for _, ft in ipairs(fts) do
				vim.list_extend(effective_fts, buflocal_extend[ft] or {})
			end
			vim.list_extend(effective_fts, fts)
		else
			effective_fts = fts
		end

		return effective_fts
	end,
	load_ft_func = require("luasnip.extras.filetype_functions").extend_load_ft({
		markdown = {"lua", "json"},
		python = {"ipynb"}
	}),
	snip_env = {
		__snip_env_behaviour = "set",
		ms = ls.multi_snippet,
		ms_add = function(...)
			local m_s = ls.multi_snippet(...)
			table.insert(getfenv(2).ls_file_snippets, m_s)
		end,
		s_add = function(...)
			local snip = ls.s(...)
			snip.metadata = debug.getinfo(2)
			table.insert(getfenv(2).ls_file_snippets, snip)
		end,
		s_add_auto = function(...)
			local snip = ls.s(...)
			table.insert(getfenv(2).ls_file_autosnippets, snip)
		end,
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
		parse_add = function(...)
			local p = ls.extend_decorator.apply(ls.parser.parse_snippet, {}, {dedent = true, trim_empty = true})
			local snip = p(...)
			table.insert(getfenv(2).ls_file_snippets, snip)
		end,
		parse_add_auto = function(...)
			local p = ls.extend_decorator.apply(ls.parser.parse_snippet, {}, {dedent = true, trim_empty = true})
			local snip = p(...)
			table.insert(getfenv(2).ls_file_autosnippets, snip)
		end,
		parse = ls.extend_decorator.apply(ls.parser.parse_snippet, {}, {dedent = true, trim_empty = true}),
		n = require("luasnip.extras").nonempty,
		m = require("luasnip.extras").match,
		ai = require("luasnip.nodes.absolute_indexer"),
		postfix = require("luasnip.extras.postfix").postfix,
		conds = require("luasnip.extras.expand_conditions")
	},
})

-- require("luasnip.util.log").set_loglevel("info")

ls.filetype_extend("latex", {"tex"})
ls.filetype_extend("glsl", {"c"})
ls.filetype_extend("cpp", {"c"})
ls.filetype_extend("sh", {"bash"})

vim.api.nvim_create_user_command("LuaSnipEditF", require("plugins.luasnip.ft_edit"), {})
local sl_ok, sl = pcall(require, "luasnip.extras.snip_location")
if sl_ok then
	vim.api.nvim_create_user_command("LuaSnipEditS", sl.jump_to_active_snippet, {})
end

vim.cmd [[
	inoremap <silent> <C-K> <cmd>lua ls.expand()<Cr>
	inoremap <silent> <C-L> <cmd>lua ls.jump(1)<Cr>
	inoremap <silent> <C-J> <cmd>lua ls.jump(-1)<Cr>

	snoremap <silent> <C-L> <cmd>lua ls.jump(1)<Cr>
	snoremap <silent> <C-J> <cmd>lua ls.jump(-1)<Cr>

	imap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : ''
	smap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : ''

	imap <silent><expr> <C-S-E> luasnip#choice_active() ? '<Plug>luasnip-prev-choice' : ''
	smap <silent><expr> <C-S-E> luasnip#choice_active() ? '<Plug>luasnip-prev-choice' : ''
]]

-- require("luasnip.util.log").set_loglevel("info")
require("luasnip.loaders.from_lua").lazy_load({paths = "./luasnippets"})
require("luasnip.loaders.from_lua").load({paths = {vim.fn.getcwd() .. "/.luasnippets/"}})

require("plugins.luasnip.external_update_dynamic_node")

---@meta

ms = require("luasnip").multi_snippet
ms_add = function(...)
	local m_s = require("luasnip").multi_snippet(...)
	table.insert(getfenv(2).ls_file_snippets, m_s)
end
s_add = function(...)
	local snip = require("luasnip").s(...)
	snip.metadata = debug.getinfo(2)
	table.insert(getfenv(2).ls_file_snippets, snip)
end
s_add_auto = function(...)
	local snip = require("luasnip").s(...)
	table.insert(getfenv(2).ls_file_autosnippets, snip)
end
ts_px_add = function(...)
	local ts_postfix = require("luasnip.extras.treesitter_postfix").treesitter_postfix
	local snip = ts_postfix(...)
	table.insert(getfenv(2).ls_file_snippets, snip)
end
px_add = function(...)
	local postfix = require("luasnip.extras.postfix").postfix
	local snip = postfix(...)
	table.insert(getfenv(2).ls_file_snippets, snip)
end
s = require("luasnip").s
sn = require("luasnip").sn
t = require("luasnip").t
i = require("luasnip").i
f = function(func, argnodes, ...)
	return require("luasnip").f(function(args, imm_parent, user_args)
		return func(args, imm_parent.snippet, user_args)
	end, argnodes, ...)
end
-- override to enable restore_cursor.
c = function(pos, nodes, opts)
	opts = opts or {}
	opts.restore_cursor = true
	return require("luasnip").c(pos, nodes, opts)
end
d = function(pos, func, argnodes, ...)
	return require("luasnip").d(pos, function(args, imm_parent, old_state, ...)
		return func(args, imm_parent.snippet, old_state, ...)
	end, argnodes, ...)
end
isn = require("luasnip.nodes.snippet").ISN
l = require'luasnip.extras'.lambda
dl = require'luasnip.extras'.dynamic_lambda
rep = require'luasnip.extras'.rep
r = require("luasnip").restore_node
p = require("luasnip.extras").partial
types = require("luasnip.util.types")
events = require("luasnip.util.events")
util = require("luasnip.util.util")
fmt = require("luasnip.extras.fmt").fmt
fmta = require("luasnip.extras.fmt").fmta
ls = require("luasnip")
ins_generate = function(nodes)
	return setmetatable(nodes or {}, {
	__index = function(table, key)
		local indx = tonumber(key)
		if indx then
			local val = require("luasnip").i(indx)
			rawset(table, key, val)
			return val
		end
	end})
end
parse_add = function(...)
	local p = require("luasnip").extend_decorator.apply(require("luasnip").parser.parse_snippet, {}, {dedent = true, trim_empty = true})
	local snip = p(...)
	table.insert(getfenv(2).ls_file_snippets, snip)
end
parse_add_auto = function(...)
	local p = require("luasnip").extend_decorator.apply(require("luasnip").parser.parse_snippet, {}, {dedent = true, trim_empty = true})
	local snip = p(...)
	table.insert(getfenv(2).ls_file_autosnippets, snip)
end
parse = require("luasnip").extend_decorator.apply(require("luasnip").parser.parse_snippet, {}, {dedent = true, trim_empty = true})
n = require("luasnip.extras").nonempty
m = require("luasnip.extras").match
ai = require("luasnip.nodes.absolute_indexer")
postfix = require("luasnip.extras.postfix").postfix
ts_postfix = require("luasnip.extras.treesitter_postfix").treesitter_postfix
conds = require("luasnip.extras.expand_conditions")
k = require("luasnip.nodes.key_indexer").new_key
opt = (function()
	if pcall(require, "luasnip.nodes.optional_arg") then
		return require("luasnip.nodes.optional_arg").new_opt
	else
		return nil
	end
end)()

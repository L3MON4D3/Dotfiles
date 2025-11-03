---@meta

ms = require("luasnip").multi_snippet
ms_add = require("luasnip").multi_snippet
s_add = require("luasnip").s
s_add_auto = require("luasnip").s
ts_px_add = require("luasnip.extras.treesitter_postfix").treesitter_postfix
px_add = require("luasnip.extras.postfix").postfix
s = require("luasnip").s
sn = require("luasnip").sn
t = require("luasnip").t
i = require("luasnip").i
f = require("luasnip").f
-- override to enable restore_cursor.
c = require("luasnip").c
d = require("luasnip").d
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
parse_add = require("luasnip").parser.parse_snippet
parse_add_auto = require("luasnip").parser.parse_snippet
parse = require("luasnip").parser.parse_snippet
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

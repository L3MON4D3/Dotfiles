local ls = require("luasnip")

local snip_defs = {
	s = ls.s,
	sn = ls.sn,
	t = ls.t,
	i = ls.i,
	f = ls.f,
	-- override to enable restore_cursor.
	c = function(pos, nodes, opts)
		opts = opts or {}
		opts.restore_cursor = true
		return ls.c(pos, nodes, opts)
	end,
	d = ls.d,
	isn = require("luasnip.nodes.snippet").ISN,
	psn = require("luasnip.nodes.snippet").PSN,
	l = require'luasnip.extras'.l,
	rep = require'luasnip.extras'.rep,
	r = ls.restore_node,
	p = require("luasnip.extras").partial,
	types = require("luasnip.util.types"),
	events = require("luasnip.util.events"),
	util = require("luasnip.util.util"),
	fmt = require("luasnip.extras.fmt").fmt,
	ls = ls,
}

local function setup_snip_env()
	setfenv(2, vim.tbl_extend("force", _G, snip_defs))
end

return {
	setup_snip_env = setup_snip_env,
}

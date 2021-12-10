local ls = require("luasnip")

local snip_defs = {
	s = ls.s,
	sn = ls.sn,
	t = ls.t,
	i = ls.i,
	f = ls.f,
	c = ls.c,
	d = ls.d,
	isn = require("luasnip.nodes.snippet").ISN,
	psn = require("luasnip.nodes.snippet").PSN,
	l = require'luasnip.extras'.l,
	r = require'luasnip.extras'.rep,
	p = require("luasnip.extras").partial,
	types = require("luasnip.util.types"),
	events = require("luasnip.util.events"),
	util = require("luasnip.util.util"),
	fmt = require("luasnip.extras.fmt").fmt,
}

local function setup_snip_env()
	setfenv(2, vim.tbl_extend("force", _G, snip_defs))
end

return {
	setup_snip_env = setup_snip_env,
}

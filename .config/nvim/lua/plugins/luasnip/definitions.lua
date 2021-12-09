local ls = require("luasnip")

local snip_const = {
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
	setfenv(2, setmetatable(_G, {
		__index = setmetatable(snip_const, getmetatable(_G))
	} ))
end

local function remove_snip_env()
	setfenv(2, setmetatable(_G, getmetatable(getmetatable(_G).__index)))
end

return {
	setup_snip_env = setup_snip_env,
	remove_snip_env = remove_snip_env
}
